class Purchase < ActiveRecord::Base

  serialize :properties               

  belongs_to  :consumer
  belongs_to  :payer
  belongs_to  :retailer
  

  def self.with_info(payer_id, consumer_id)
    if consumer_id
      Purchase.where("consumer_id = ?", consumer_id).includes(:consumer, :retailer).all
    else
      Purchase.where("payer_id = ?", payer_id).includes(:consumer, :retailer).all
    end
  end

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
                 :properties => {                                     # properties are the black/whitelistable items           
                    "retailer" =>     retailer,
                    "title" =>        title,
                    "category" =>     title_rec.category,                                   
                    "esrb_rating" =>  title_rec.esrb_rating,
                    "pegi_rating" =>  title_rec.pegi_rating
                  },
                  :params => {
                    "merchant" =>     params[:merchant],              # the params passed to Paykido upon invocation
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
  #               'approve'/'deny' is used when a human being (parent) authorizes it himself.

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
    self.authorization_type ==  "Approved" or 
    self.authorization_type ==  "Denied" or
    self.authorization_type ==  "PendingPayer"
  end
    
  def approve!(params=nil)
    self.update_attributes!(
      :authorized => true,
      :authorization_type => "Approved",
      :authorization_date => Time.now) 
      
    # temporary - get one hash of 'properties' from the form and iterate over it without knowing what it includes
    return unless params
    params.each do |property, value|
      if property == 'retailer' or
         property == 'title' or
         property == 'category' or
         property == 'esrb_rating' or
         property == 'pegi_rating'
      self.consumer.whitelist!(property, self.properties[property])
      end 
    end
    
    begin
      message = "Congrats! Your parent has just approved your purchase request. The item is yours!"
      Sms.send(self.consumer.billing_phone, message) 
    rescue
      return false
    end

  end
  
  def approved?
    self.authorization_type == "Approved"
  end
  
  def deny!(params=nil!)
    self.update_attributes!(
      :authorized => false,
      :authorization_type => "Denied",
      :authorization_date => Time.now) 
    # temporary - get one hash of 'properties' from the form and iterate over it without knowing what it includes
    return unless params
    params.each do |property, value|
      if property == 'retailer' or
         property == 'title' or
         property == 'category' or
         property == 'esrb_rating' or
         property == 'pegi_rating'
      self.consumer.blacklist!(property, self.properties[property])
      end 
    end
    
    begin
      message = "We are sorry. Your parent has just declined your purchase request."
      Sms.send(self.consumer.billing_phone, message) 
    rescue
      return false
    end

  end
  
  def denied?
    self.authorization_type == "Denied"       
  end
  
  def authorized?
    self.authorized and !self.manually_handled?
  end
  
  def unauthorized?
    !self.authorized and self.authorization_type and !self.manually_handled?
  end
  
  def request_approval
    
    begin
      UserMailer.purchase_approval_email(self).deliver
    rescue
      return false
    end
      
    begin
      message = "Hi from Paykido! #{self.consumer.name} asks that you approve #{self.product} from #{self.retailer.name}. See our email for details"
      Sms.send(self.payer.phone, message) 
    rescue
      return false
    end
     
  end

  def account_for!   
    self.consumer.deduct!(self.amount)   
  end

end
