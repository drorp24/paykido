require 'digest/md5'
require 'uri'

class TokenAPI
  include ProximoParty
  format :xml
  base_uri 'https://test.safecharge.com'
end

class PPP
  include HTTParty
  format :json
  base_uri 'https://secure.Gate2Shop.com'
end

class Listener
  include ProximoParty
  format :html
  base_uri Paykido::Application.config.listener_base_uri
end

class TestListener
  include ProximoParty
  format :html
  base_uri Paykido::Application.config.test_listener_base_uri
end

class Purchase < ActiveRecord::Base

  serialize :properties               
  serialize :params               

  belongs_to  :consumer
  belongs_to  :payer
  belongs_to  :retailer
  
  has_many    :transactions
  has_many    :notifications
  has_many    :parameters
  has_many    :payments
  
  scope :pending,   where("authorization_type = ?", 'PendingPayer')
  scope :approved,  where("authorized = ?", true)
  scope :declined,  where("authorized = ? AND authorization_type != ?", false, "PendingPayer")

  def create_transaction!(params)    

    self.transactions.create!( 
        :trx_type => 'Manual',
        :ppp_status =>  params[:ppp_status],
        :PPP_TransactionID => params[:PPP_TransactionID],
        :responsechecksum => params[:responsechecksum],
        :TransactionID => params[:TransactionID],
        :status => params[:status],
        :userid => params[:userid],
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :Email => params[:Email],
        :address1 => params[:address1],
        :address2 => params[:address2],
        :country => params[:country],
        :state => params[:state],
        :city => params[:city],
        :zip => params[:zip],
        :phone1 => params[:phone1],
        :nameOnCard => params[:nameOnCard],
        :cardNumber => params[:cardNumber],
        :expMonth => params[:expMonth],
        :expYear => params[:expYear],
        :token => params[:token],
        :IPAddress => params[:IPAddress],
        :ExErrCode => params[:ExErrCode],
        :ErrCode => params[:ErrCode],
        :AuthCode => params[:AuthCode],
        :message => params[:message],
        :responseTimeStamp => params[:responseTimeStamp],
        :Reason => params[:Reason],
        :ReasonCode => params[:ReasonCode]
      )                                                      
        
  end


  def self.with_info(payer_id, consumer_id)

    if consumer_id
      Purchase.where("payer_id = ? and consumer_id = ?", payer_id, consumer_id).order('created_at DESC').includes(:consumer, :retailer)
    else
      Purchase.where("payer_id = ?", payer_id).order('created_at DESC').includes(:consumer, :retailer)
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

  def requires_manual_payment?
    Paykido::Application.config.always_pay_manually or
    !self.payer.registered?
  end

  def g2spp
    # return the url to redirect to for manual payment including all parameters

    time_stamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
       
      URI.escape(
      Paykido::Application.config.g2spp + "?" +
      "merchant_id=" + Paykido::Application.config.merchant_id + "&" +
      "merchant_site_id=" + Paykido::Application.config.merchant_site_id + "&" +
      "total_amount=" + amount.to_s + "&" +
      "currency=" + self.currency + "&" +
      "item_name_1=" + self.product + "&" +
      "item_amount_1=" + self.amount.to_s + "&" +
      "item_quantity_1=" + "1" + "&" +
      "time_stamp=" + time_stamp + "&" +
      "version=" +   Paykido::Application.config.version + "&" +
      "customField1=" + "payment" + "&" +
      "customField2=" + self.payer_id.to_s + "&" +
      "customField3=" + self.id.to_s + "&" +
      "&merchantLocale=" + I18n.locale.to_s + "&" +
      "checksum=" + self.checksum(time_stamp) + test_fields
      )
    
  end
  
  def test_fields

    return "" unless Paykido::Application.config.populate_test_fields
    
    "&first_name=Mom" +
    "&last_name=Smith" +
    "&email=mom@paykido.com" +
    "&address1=Shamgar 23" +
    "&city=Tel Aviv" +
    "&country=Israel" +
    "&zip=69935" +
    "&phone1=0542343220"
    
  end

  def checksum(time_stamp)
    str = Paykido::Application.config.secret_key +
          Paykido::Application.config.merchant_id +
          self.currency +
          self.amount.to_s +
          self.product +
          self.amount.to_s +
          "1" +
          time_stamp
          
    Digest::MD5.hexdigest(str)          
  end
  
  def pay_by_token!(ip)
    # call the token interface here with payer's saved Token and TransactionID (token)

    return false unless self.payer.registered?  
    if Paykido::Application.config.skip_g2s
      @paid_by_token = true
      return true
    end  
    token = self.payer.token

    begin
    token_response  = TokenAPI.post('/service.asmx/Process', :body => {
      :sg_VendorID  => Paykido::Application.config.sg_VendorID,  
      :sg_MerchantName  => Paykido::Application.config.sg_MerchantName, 
      :sg_MerchantPhoneNumber  => Paykido::Application.config.sg_MerchantPhoneNumber, 
      :sg_WebSiteID  => Paykido::Application.config.sg_WebSiteID , 
      :sg_ClientLoginID  => Paykido::Application.config.sg_ClientLoginID ,
      :sg_ClientPassword  => Paykido::Application.config.sg_ClientPassword , 
      :sg_Descriptor  => Paykido::Application.config.sg_Descriptor ,
      :sg_NameOnCard => token.NameOnCard ,
      :sg_CCToken => token.CCToken  ,
      :sg_ExpMonth => token.ExpMonth || '12',           # ToDo: Temp                        
      :sg_ExpYear => token.ExpYear   || '13',           # ToDo: Temp                
      :sg_TransType => 'Sale' ,
      :sg_Currency  => self.currency ,
      :sg_Amount  => self.amount ,
      :sg_TransactionID => token.TransactionID ,
      :sg_Rebill => "1",
      :sg_FirstName  => token.FirstName ,
      :sg_LastName  => token.LastName ,
      :sg_Address  => token.Address ,
      :sg_City  => token.City ,
      :sg_State  => token.State ,
      :sg_Zip  => token.State ,
      :sg_Country  => token.Country ,
      :sg_Phone  => token.Phone ,
      :sg_IPAddress  => ip, 
      :sg_Email  => token.Email,           
      :sg_ClientUniqueID => self.id,
      :sg_Version => Paykido::Application.config.sg_Version,
      :sg_ResponseFormat => "4"
    })
    rescue => e
      Rails.logger.info("Token was rescued. Following is the error:")
      Rails.logger.info(e)
      @paid_by_token = false
      return
    else
      Rails.logger.info("Token call itself was succesfull. Status: #{token_response.parsed_response["Response"]["Status"]}. Following is the full response:")
      Rails.logger.info(token_response.inspect)
   end
   
    response = token_response.parsed_response["Response"]
 
    reason = response["ReasonCodes"]["Reason"]["__content__"] if response["ReasonCodes"] and response["ReasonCodes"]["Reason"] and response["ReasonCodes"]["Reason"]["__content__"]

    self.transactions.create!( 
      :trx_type => 'Token',
      :TransactionID => response["TransactionID"],
      :status => response["Status"],
      :AuthCode => response["AuthCode"],
      :Reason => reason,
      :ExErrCode => response["ExErrCode"],
      :ErrCode => response["ErrCode"],
      :token => token.CCToken
    )                                                      

    @paid_by_token = response["Status"] == 'APPROVED'

  end
  
  
  def paid_by_token?
    @paid_by_token
  end


  def token_request  # DELETE
  # note: assumes self.payer.registered otherwise it will fail
    

    URI.escape(
      Paykido::Application.config.token_gateway + 
      "sg_VendorID=" + Paykido::Application.config.sg_VendorID + "&" + 
      "sg_MerchantName=" + Paykido::Application.config.sg_MerchantName + "&" +
      "sg_MerchantPhoneNumber=" + Paykido::Application.config.sg_MerchantPhoneNumber + "&" +
      "sg_WebSiteID=" + Paykido::Application.config.sg_WebSiteID + "&" + 
      "sg_ClientLoginID=" + Paykido::Application.config.sg_ClientLoginID + "&" +
      "sg_ClientPassword=" + Paykido::Application.config.sg_ClientPassword + "&" + 
      "sg_Descriptor=" + Paykido::Application.config.sg_Descriptor + "&" +
      "sg_NameOnCard" + token.NameOnCard + "&" +
      "sg_CCToken" + token.CCToken + "&" + 
      "sg_ExpMonth" + token.ExpMonth + "&" +
      "sg_ExpYear" + token.ExpYear + "&" + 
      "sg_TransType=Sale&" + 
      "sg_Currency=" + self.currency + "&" +
      "sg_Amount=" + self.amount + "&" +
      "sg_TransactionID" + token.TransactionID + "&" +
      "sg_Rebill=1&" +
      "sg_FirstName=" + token.FirstName + "&" +
      "sg_LastName=" + token.LastName + "&" +
      "sg_Address=" + token.Address + "&" +
      "sg_City=" + token.City + "&" +
      "sg_State=" + token.State + "&" +
      "sg_Zip=" + token.State + "&" +
      "sg_Country=" + token.Country + "&" +
      "sg_Phone=" + token.Phone + "&" +
      "sg_IPAddress=" + request.remote_ip + "&" +
      "sg_Email=" + token.Email
      )      
    
  end
  
  def notify_merchant(status, event)
    
    return "OK" if Paykido::Application.config.skip_g2s

    begin
      str = Paykido::Application.config.return_secret_key +
            self.PP_TransactionID.to_s +
            status +
            self.amount.to_s +
            self.currency +
            ""  +
            self.id.to_s
            
      hash = Digest::MD5.hexdigest(str)          
  
      Rails.logger.info("About to send_notification with: orderid=#{self.PP_TransactionID}&status=#{status}&amount=#{self.amount.to_s}&currency=#{self.currency}&reason=&purchase_id=#{id.to_s}&checksum=#{hash}") 
      send_notification(status, hash, event)
    rescue => e

      Rails.logger.info("Notify merchant was rescued. Following is the error:")
      Rails.logger.info(e)
      notification_response = e
      notification_status = e
    end

  end

  def send_notification(status, hash, event)

    Rails.logger.info("ENTER send_notification") 

    begin
    listener_response  = Listener.get(Paykido::Application.config.listener_path, :query => {
      :orderid  =>  self.PP_TransactionID    ,  
      :status  => status, 
      :amount  => self.amount,
      :currency  => self.currency , 
      :reason  => '' ,
      :purchase_id => self.id,
      :checksum  => hash
    })
    rescue => e

      Rails.logger.info("Notification Listener was rescued. Following is the error:")
      Rails.logger.info(e)
      notification_response = "Unreachable"
      notification_status = "Unreachable"
#      raise "NotificationListener Unreachable"

    else

      Rails.logger.info("Following is the full response (listener_response)")
      Rails.logger.info(listener_response.inspect)
      Rails.logger.info("Following is listener_response.parsed_response")
      Rails.logger.info(listener_response.parsed_response)
      Rails.logger.info('Following is the code:')
      Rails.logger.info(listener_response.code)

      notification_response = listener_response.parsed_response

      if listener_response.code != 200
        Rails.logger.info("NotificationListener Unauthorized raised")
#        raise "NotificationListener Unauthorized"
        notification_status = "code: " + listener_response.code.to_s
      elsif listener_response.parsed_response == "ERROR"
        Rails.logger.info("NotificationListener ERROR raised")
#        raise "NotificationListener ERROR"
        notification_status = listener_response.parsed_response
      elsif listener_response.parsed_response == "ORDERNOTFOUND"
        if self.params[:mode] == 'M'
          Rails.logger.info("ORDERNOTFOUND but called with params[:mode] == 'M")
          notification_status = "OK"
        else   
          Rails.logger.info("NotificationListener ORDERNOTFOUND raised")
          Rails.logger.info("self.params[:mode] is: " + self.params[:mode])
          Rails.logger.info("self.id is: " + self.id.to_s)
   #       raise "NotificationListener ORDERNOTFOUND"
          notification_status = listener_response.parsed_response
        end
      else
        Rails.logger.info("Nothing raised. Successfully completed")
        notification_status = "OK"        
      end
   end
   
   @notification = self.notifications.create(
      :orderid =>   self.PP_TransactionID.to_s,
      :status  =>   notification_status, 
      :response =>  notification_response,
      :amount  =>   self.amount,
      :currency =>  self.currency , 
      :reason  =>   "code: " + listener_response.code.to_s,
      :checksum  => hash.to_s,
      :event =>     event     
    )
   
   if Paykido::Application.config.use_test_listener

      test_listener_response  = TestListener.get(Paykido::Application.config.test_listener_path, :query => {
        :orderid  =>  self.PP_TransactionID    ,  
        :status  => status, 
        :amount  => self.amount,
        :currency  => self.currency , 
        :reason  => '' ,
        :purchase_id => self.id,
        :checksum  => hash})
        
      Rails.logger.info ""
      Rails.logger.info("Test listener response (listener_response)")
      Rails.logger.info(test_listener_response.inspect)
      Rails.logger.info ""
     
   end

   Rails.logger.info("EXIT send_notification") 
   return notification_status

  end
#  handle_asynchronously :send_notification if Paykido::Application.config.use_delayed_job
  
  def set_rules!(params)
    # implement the rules parent has set while manually approving the purchase
    # params should contain a normal hash and for that 
  end

  def authorize!
       
    self.authorized = false

    unless self.consumer.confirmed? 
      self.authorization_property = "confirmation"
      self.authorization_value = "missing"
      self.authorization_type = "unqualified"
      self.authorization_date = Time.now
      self.save!
      return      
    end

    unless self.payer.registered? 
      self.authorization_property = "registration"
      self.authorization_value = "missing"
      self.authorization_type = "PendingPayer"
      self.authorization_date = Time.now
      self.save!
      return      
    end

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
    elsif self.consumer.under_threshold and self.amount <= self.consumer.under_threshold
      self.authorization_property = "Amount"
      self.authorization_value = self.amount
      self.authorization_type = "Under Threshold"
      self.authorized = true
    elsif self.consumer.over_threshold and self.amount > self.consumer.over_threshold
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
    self.authorization_property = "Approval"
    self.authorization_value = "required"
    self.authorization_type = "PendingPayer"
  end

  def require_approval!
    self.update_attributes!(
      :authorized => false,
      :authorization_date => Time.now,
      :authorization_property => "Confirmation",
      :authorization_value => "required",
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

  def failed!

    last_transaction = self.transactions.last if self.transactions.any?

    self.update_attributes!(
      :authorized => false,
      :authorization_property => 'Token',
      :authorization_value => 'failed',
      :authorization_type => 'PendingPayer',
      :authorization_date => Time.now)       
  end
  
  def approval_counter(property)
    
    return false unless property == 'retailer'
    
    Purchase.where("payer_id = ? and retailer_id = ? and authorization_type = ?", self.payer_id, self.retailer_id, "Approved").count
      
  end

  def denial_counter(property)
    
    return false unless property == 'retailer'
    
    Purchase.where("payer_id = ? and retailer_id = ? and authorization_type = ? and id != ?", self.payer_id, self.retailer_id, "Declined", self.id).count
      
  end
  
  # ToDo: Delete if not used
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
  
  def approved?
    self.authorization_type == "Approved"
  end
  
  def decline!(params=nil)
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
      if Paykido::Application.config.use_delayed_job
        UserMailer.delay.purchase_approval_email(self)
      else
        UserMailer.purchase_approval_email(self).deliver
      end
    rescue
      return false
    end
          
    begin
      message = "Hi from Paykido! #{self.consumer.name} asks that you approve #{self.product} from #{self.retailer.name}. See our email for details"
      Sms.send(self.payer.phone, message) 
    rescue
      return false
    end

    Sms.notify_consumer(self.consumer, 'approval', 'request', self)
    
  end

  def account_for!   
  end
  
  def notification_failed!
    self.authorized = false
    self.authorization_type =     'PendingPayer'
    self.authorization_property = 'Notification'
    self.authorization_value =    'failed'
    self.authorization_date =     Time.now
    self.save!
  end
  
  def response(status)
    @response                 = {}
    @response[:status]        = status
    @response[:property]      = self.authorization_property.to_s 
    @response[:value]         = self.authorization_value.to_s 
    @response[:type]          = self.authorization_type.to_s 
    @response[:orderid]       = self.PP_TransactionID
    if status == 'registering'
      @response[:message]      = "Parent contacted to confirm consumer"
    elsif status == 'pending'
      @response[:message]     = 'Purchase requires manual approval'
    elsif status == 'approved'
      @response[:message]     = 'Purchase is approved'
    elsif status == 'declined' 
      @response[:message]     = "Purchase is declined. #{self.authorization_property} #{self.authorization_value.to_s} is #{self.authorization_type}"
    elsif status == 'unregistered' 
      @response[:message]      = "Please register to Paykido first"
    elsif status == 'failed'
      @response[:message]      = "An error occured. Please call Paykido for help"
    else
      @response[:message]      = "Something went wrong. Please call Paykido for help"
    end
    @response[:purchase_id]    = self.id
    str = 
      Paykido::Application.config.return_secret_key +
      @response[:status]            +
      @response[:property]          +
      @response[:value]             +
      @response[:type]              +
      @response[:message]           +
      @response[:orderid].to_s      +
      @response[:purchase_id].to_s 
      
      @response[:checksum]      = Digest::MD5.hexdigest(str)
      
      return @response

  end

end
