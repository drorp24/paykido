class Purchase < ActiveRecord::Base

  serialize :properties               #properties are the black/whitelistable items

  belongs_to  :consumer
  belongs_to  :payer
  belongs_to  :retailer
  
  def self.create_new!(payer, consumer, retailer, title, product, amount, params)
    
    retailer_id = Retailer.find_or_create_by_name(retailer).id
    title_rec =   Title.find_or_create_by_name(title)
    
    self.create!(:payer_id =>         payer.id,
                 :consumer_id =>      consumer.id,
                 :retailer_id =>      retailer_id,
                 :title =>            title,    
                 :product =>          product,             
                 :amount =>           amount,
                 :date =>             Time.now,
                 :properties => {                                  
                    "retailer" =>     retailer,
                    "title" =>        title,
                    "category" =>     title_rec.category,                                   
                    "esrb_rating" =>  title_rec.esrb_rating,
                    "pegi_rating" =>  title_rec.pegi_rating
                  },
                  :params => {
                    "merchant" =>     params[:merchant],
                    "app" =>          params[:app],
                    "product" =>      params[:product],
                    "amount" =>       params[:amount],
                    "currency" =>     params[:currency],
                    "userid" =>       params[:userid],
                    "mode" =>         params[:mode],
                    "tid" =>          params[:tid],
                    "hash" =>         params[:hash]
                  }
                  )
  end

  # terminology:  'authorize'/'unauthorize' is used when Paykido programmatically authorizes purchase.
  #               'approve'/'decline' is used when a human being (parent) authorizes it (or not).

  def authorize!
       
    self.authorized = false

    self.properties.each {|property,value| 
      if self.consumer.blacklisted?(property, value)  
        self.authorization_property = property
        self.authorization_value = value
        self.authorization_type = "Blacklisted"
        self.authorization_date = Time.now
        self.save!
        return
      end
    }
          
    if self.consumer.balance <= 0
      self.authorization_property = "Balance"
      self.authorization_value = self.consumer.balance
      self.authorization_type = "insufficient"  
    elsif self.consumer.balance < self.amount
      self.authorization_property = "Balance"
      self.authorization_value = self.consumer.balance
      self.authorization_type = "insufficient"
    elsif self.amount <= self.consumer.auto_authorize_under
      self.authorization_property = "Amount"
      self.authorization_value = self.amount
      self.authorization_type = "Under Threshold"
      self.authorized = true
    elsif self.amount > self.consumer.auto_deny_over
      self.authorization_property = "Amount"
      self.authorization_value = self.amount
      self.authorization_type = "Too High"
      
    else
      
      self.properties.each {|property,value| 
        if self.consumer.whitelisted?(property, value)  
          self.authorization_property = property
          self.authorization_value = value
          self.authorization_type = "Whitelisted"
          self.authorized = true
          self.authorization_date = Time.now
          self.save!
          return
        end
    }

      self.require_approval
    end
    
    self.authorization_date = Time.now
    self.save!
    
  end  

  def require_approval
    self.authorization_type = "PendingPayer"
  end

  def require_approval!
    self.update_attributes!(
      :authorization_type => "PendingPayer")
  end
  
  def requires_approval?
    self.authorization_type == "PendingPayer"
  end

  def manually_handled?
    self.authorization_type == "Approved" or 
    self.authorization_type == "Declined" or
    self.authorization_type ==  "PendingPayer"
  end
    
  def approval!(params)
    if params[:activity] == 'approved'
      self.approve!
    elsif params[:activity] == 'declined'
      self.decline!
    else
      return false
    end
  end

  def approve!
    self.update_attributes!(
      :authorized => true,
      :authorization_type => "Approved",
      :authorization_date => Time.now) 
  end
  
  def approved?
    self.authorization_type == "Approved"
  end
  
  def decline!
    self.update_attributes!(
      :authorized => false,
      :authorization_type => "Declined",
      :authorization_date => Time.now) 
  end
  
  def declined?
    self.authorization_type == "Declined"       
  end
  
  def authorized?
    self.authorized and !self.manually_handled?
  end
  
  def unauthorized?
    !self.authorized and self.authorization_type and !self.manually_handled?
  end
  
  def account_for!   
    self.consumer.deduct!(self.amount)   
  end

end
