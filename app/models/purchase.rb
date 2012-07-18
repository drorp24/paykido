require 'digest/md5'
require 'uri'

class Token
  include HTTParty
  format :xml
  base_uri 'https://test.safecharge.com'
end

class Purchase < ActiveRecord::Base

  serialize :properties               

  belongs_to  :consumer
  belongs_to  :payer
  belongs_to  :retailer
  
  has_many    :transactions
  has_many    :payments
  
  scope :pending, where(:authorization_type => 'PendingPayer')

  def create_transaction!(params)    

    self.transactions.create!( 
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

  def requires_manual_payment?
    Paykido::Application.config.always_pay_manually or
    !self.payer.registered?
  end

  def g2spp
    # return the url to redirect to for manual payment including all parameters

    time_stamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
       
      URI.escape(
      "https://secure.Gate2Shop.com/ppp/purchase.do?" +
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
      "customField2=" + self.id.to_s + "&" +
      "&merchantLocale=" + I18n.locale.to_s + "&" +
      "checksum=" + self.checksum(time_stamp) + test_fields
      )
    
  end
  
  def test_fields

    return "" unless Paykido::Application.config.populate_test_fields
    
    "&first_name=Dror" +
    "&last_name=Poliak" +
    "&email=drorp24@yahoo.com" +
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
    # call the token interface here with payer's saved Token and TransactionID (registration)

    return false unless self.payer.registered?    
    registration = self.payer.registration

    begin
    token_response  = Token.post('/service.asmx/Process', :body => {
      :sg_VendorID  => Paykido::Application.config.sg_VendorID,  
      :sg_MerchantName  => Paykido::Application.config.sg_MerchantName, 
      :sg_MerchantPhoneNumber  => Paykido::Application.config.sg_MerchantPhoneNumber, 
      :sg_WebSiteID  => Paykido::Application.config.sg_WebSiteID , 
      :sg_ClientLoginID  => Paykido::Application.config.sg_ClientLoginID ,
      :sg_ClientPassword  => Paykido::Application.config.sg_ClientPassword , 
      :sg_Descriptor  => Paykido::Application.config.sg_Descriptor ,
      :sg_NameOnCard => registration.NameOnCard ,
      :sg_CCToken => registration.CCToken  ,
      :sg_ExpMonth => registration.ExpMonth ,                       
      :sg_ExpYear => registration.ExpYear  ,                        
      :sg_TransType => 'Sale' ,
      :sg_Currency  => self.currency ,
      :sg_Amount  => self.amount ,
      :sg_TransactionID => registration.TransactionID ,
      :sg_Rebill => "1",
      :sg_FirstName  => registration.FirstName ,
      :sg_LastName  => registration.LastName ,
      :sg_Address  => registration.Address ,
      :sg_City  => registration.City ,
      :sg_State  => registration.State ,
      :sg_Zip  => registration.State ,
      :sg_Country  => registration.Country ,
      :sg_Phone  => registration.Phone ,
      :sg_IPAddress  => ip, 
      :sg_Email  => registration.Email,           
      :sg_ClientUniqueID => self.id,
      :sg_Version => Paykido::Application.config.sg_Version,
      :sg_ResponseFormat => "4"
    })
    rescue => e
      Rails.logger.info("token was rescued. Following is the error:")
      Rails.logger.info(e)
      @paid_by_token = false
      return
    else
      Rails.logger.info("token was succesfull. Following is the response:")
      Rails.logger.info(token_response.inspect)
   end
   
    response = token_response.parsed_response["Response"]
 
    self.transactions.create!( 
      :trx_type => 'token',
      :TransactionID => response["TransactionID"],
      :status => response["Status"],
      :AuthCode => response["AuthCode"],
      :Reason => response["ReasonCodes"]["Reason"]["code"],
      :ExErrCode => response["ExErrCode"],
      :ErrCode => response["ErrCode"]
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
      "sg_NameOnCard" + registration.NameOnCard + "&" +
      "sg_CCToken" + registration.CCToken + "&" + 
      "sg_ExpMonth" + registration.ExpMonth + "&" +
      "sg_ExpYear" + registration.ExpYear + "&" + 
      "sg_TransType=Sale&" + 
      "sg_Currency=" + self.currency + "&" +
      "sg_Amount=" + self.amount + "&" +
      "sg_TransactionID" + registration.TransactionID + "&" +
      "sg_Rebill=1&" +
      "sg_FirstName=" + registration.FirstName + "&" +
      "sg_LastName=" + registration.LastName + "&" +
      "sg_Address=" + registration.Address + "&" +
      "sg_City=" + registration.City + "&" +
      "sg_State=" + registration.State + "&" +
      "sg_Zip=" + registration.State + "&" +
      "sg_Country=" + registration.Country + "&" +
      "sg_Phone=" + registration.Phone + "&" +
      "sg_IPAddress=" + request.remote_ip + "&" +
      "sg_Email=" + registration.Email
      )      
    
  end
  
  def notify_merchant(status)
    # update PP backend with a transaction's new status: 'pending', 'approved' or 'declined' (PP_TransactionID)  
    return if status == 'failed'
  end
  
  def set_rules!(params)
    # implement the rules parent has set while manually approving the purchase
    # params should contain a normal hash and for that 
  end

  def authorize!
       
    self.authorized = false

    unless self.payer.registered? 
      self.authorization_property = "registration"
      self.authorization_value = "missing"
      self.require_approval
      self.authorization_date = Time.now
      self.save!
      return      
    end

    unless self.consumer.confirmed? 
      self.authorization_property = "confirmation"
      self.authorization_value = "missing"
      self.require_approval
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
