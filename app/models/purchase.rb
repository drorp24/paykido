require 'digest/md5'
class Purchase < ActiveRecord::Base

  serialize :properties               

  belongs_to  :consumer
  belongs_to  :payer
  belongs_to  :retailer
  
  has_many    :transactions
  has_many    :payments
  

  def self.with_info(payer_id, consumer_id, purchase_id)
    if purchase_id and !consumer_id and !payer_id
      Purchase.where("consumer_id = ?", Purchase.find(purchase_id).consumer_id).includes(:consumer, :retailer)      
    elsif consumer_id
      Purchase.where("consumer_id = ?", consumer_id).includes(:consumer, :retailer)
    else
      Purchase.where("payer_id = ?", payer_id).includes(:consumer, :retailer)
    end
  end
  
  def pending
    self.count{|purchase| purchase.authorization_type == 'PendingPayer'}
  end

  def self.create_new!(payer, consumer, retailer, title, product, amount, currency, transactionID, params)
    
    retailer_id = Retailer.find_or_create_by_name(retailer).id
    title_rec =   Title.find_or_create_by_name(title)
    
    self.create!(:payer_id =>         payer.id,
                 :consumer_id =>      consumer.id,
                 :retailer_id =>      retailer_id,
                 :title =>            title,    
                 :product =>          product,             
                 :amount =>           amount,
                 :currency =>         currency,
                 :PP_TransactionID => transactionID,
                 :date =>             Time.now,
                 :properties => {                                     # properties are the black/whitelistable items           
                    "retailer" =>     retailer,
                    "title" =>        title,
                    "category" =>     title_rec.category,                                   
                    "esrb_rating" =>  title_rec.esrb_rating,
                    "pegi_rating" =>  title_rec.pegi_rating
                  },
                  :params => params                                   # keep them as accepted
                  )
  end

  # terminology:  'authorize'/'unauthorize' is used when Paykido programmatically authorizes purchase.
  #               'approve'/'decline' is used when a human being (parent) authorizes it himself.

  def g2spp(purpose)
    # return the url to redirect to for manual payment including all parameters
    
    time_stamp = Time.now.strftime('%Y-%m-%e %H:%M:%S')

       
      "https://secure.Gate2Shop.com/ppp/purchase.do?" +
      "merchant_id=" + Paykido::Application.config.merchant_id + "&" +
      "merchant_site_id=" + Paykido::Application.config.merchant_site_id + "&" +
      "total_amount=" + "6" + "&" +
      "currency=" + self.currency + "&" +
      "item_name_1=" + CGI.escape(self.product) + "&" +
      "item_amount_1=" + "6" + "&" +
      "item_quantity_1=" + "1" + "&" +
      "time_stamp=" + CGI.escape(time_stamp) + "&" +
      "version=" +   Paykido::Application.config.version + "&" +
      "customField1=" + purpose + "&" +
      "customField2=" + self.id.to_s + 
      "checksum=" + self.checksum(time_stamp)
    
  end

  def checksum(time_stamp)
    str = Paykido::Application.config.secret_key +
          Paykido::Application.config.merchant_id +
          self.currency +
          "6" +
          CGI.escape(self.product) +
          "6" +
          "1" +
          CGI.escape(time_stamp)
          
    Digest::MD5.hexdigest(str)           
  end
  
  def pay_by_token!
    # call the token interface here with payer's saved Token and TransactionID (registration)
    # have Nokogiri parse the returned xml/string and update the @purchase accordingly

    return false unless self.payer.registered?
    
  end
  
  def paid_by_token?
    # inquires on the return value that pay_by_token inserted to @purchase
  end
  
  def notify_merchant
    # call the PP backend with purchase's saved original PP_TransactionID
    # transaction identified by PP_TransactionID will change its status to either 'pending' or 'approved' 
  end
  
  def set_rules!(params)
    # implement the rules parent has set while manually approving the purchase
    # params should contain a normal hash and for that 
  end

  def authorize!
       
    unless self.payer.registered? and Paykido::Application.config.rules_require_registration
      self.authorized = false
      self.authorization_property = "registration"
      self.authorization_value = "missing"
      self.require_approval
      self.authorization_date = Time.now
      self.save!
      return      
    end

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
    self.authorization_type ==  "Declined" or
    self.authorization_type ==  "PendingPayer"
  end
    
  def approve!
    self.update_attributes!(
      :authorized => true,
      :authorization_type => "Approved",
      :authorization_date => Time.now)       
  end
  
  def set_rules!(params=nil)

    # temporary - get one hash of 'properties' from the form and iterate over it without knowing what it includes
    return unless params and params.any?
    params.each do |property, value|
      if property == 'retailer' or
         property == 'title' or
         property == 'category' or
         property == 'esrb_rating' or
         property == 'pegi_rating'
      self.consumer.whitelist!(property, self.properties[property])  # params would include whether to blacklist or whitelist too
      end 
    end
        
  end
  
  def notify_consumer (mode, status)
    
    return false unless mode and status
    
    if mode == 'manual'
      if      status == 'approved'
        message = "Congrats, #{self.consumer.name}! Your parent has just approved your purchase request. The item is yours!"
      elsif    status == 'declined'  
        message = "We are sorry. Your parent has just declinedd your purchase request."
      elsif   status == 'failed'  
        message = "We are sorry. Something went wrong while trying to approve your purchase. Please contact Paykido help desk for details"  
      else
        return false  
      end 
    else
      if      status == 'approved' 
        message = "Congrats, #{self.consumer.name}! Paykido just approved your purchase request. The item is yours!"
      elsif   status == 'declined'   
        message = "We are sorry. This purchase is not compliant with you parents rules!"
      elsif   status == 'failed'  
        message = "We are sorry. Something went wrong while trying to approve your purchase. Please contact Paykido help desk for details"  
      elsif   status == 'pending'  
        message = "Wait... This requires manual approved. We'll notify you once it gets approved!"  
      else
        return false  
      end 
    end    
    
    begin
      Sms.send(self.consumer.billing_phone, message) 
    rescue
      return false
    end
 
  end     
  
  def approved?
    self.authorization_type == "Approved"
  end
  
  def decline!(params=nil!)
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
