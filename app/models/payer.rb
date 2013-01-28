class Payer < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  has_many  :consumers
  has_many  :purchases
  has_many  :tokens
  has_many  :notifications
  has_many  :allowances, :through => :consumers
  has_many  :rules, :through => :consumers
  
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  before_save :reset_authentication_token

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :phone


  def g2spp(params)
    # return the url to redirect to for manual payment including all parameters

    time_stamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    item_name = "Registration (no payment)"
       
      URI.escape(
      "https://secure.Gate2Shop.com/ppp/purchase.do?" +
      "merchant_id=" + Paykido::Application.config.merchant_id + "&" +
      "merchant_site_id=" + Paykido::Application.config.merchant_site_id + "&" +
      "total_amount=" + "0" + "&" +
      "currency=" + 'EUR' + "&" +
      "item_name_1=" + item_name + "&" +
      "item_amount_1=" + "0" + "&" +
      "item_quantity_1=" + "1" + "&" +
      "time_stamp=" + time_stamp + "&" +
      "version=" +   Paykido::Application.config.version + "&" +
      "customField1=" + "registration" + "&" +
      "customField2=" + self.id.to_s + "&" +
      "merchantLocale=" + I18n.locale.to_s + "&" +
      "checksum=" + self.checksum(time_stamp, item_name) + populate_fields(params)
      )
    
  end
  
  def populate_fields(params)

    return '' unless 
                  params[:token]             and
                  params[:token][:FirstName] and 
                  params[:token][:LastName]  and 
                  params[:token][:Email]     and
                  params[:token][:Phone]
    
    "&first_name=" + params[:token][:FirstName] +
    "&last_name=" + params[:token][:LastName] +
    "&email=" + params[:token][:Email] +
    "&phone1=" + params[:token][:Phone]
   
  end

  def checksum(time_stamp, item_name)
    str = Paykido::Application.config.secret_key +
          Paykido::Application.config.merchant_id +
          'EUR' +
          "0" +
          item_name +
          "0" +
          "1" +
          time_stamp
          
    Digest::MD5.hexdigest(str)          
  end


  # This Token is generated following the DMN. Note: DMN may take 30-60 min some times to retutn.
  def create_token!(params)
    self.tokens.create!( 
        :status => params[:Status],
        :NameOnCard => params[:nameOnCard],
        :CCToken => params[:Token],
        :ExpMonth => params[:expMonth],
        :ExpYear => params[:expYear],
        :TransactionID => params[:TransactionID],
        :FirstName => params[:first_name],
        :LastName => params[:last_name],
        :Address => params[:address1],
        :City => params[:city],
        :State => params[:state],
        :Country => params[:country],
        :Zip => params[:zip],
        :Phone => params[:phone1],
        :Email => params[:email],
        :ExErrCode => params[:ExErrCode],
        :ErrCode => params[:ErrCode],
        :AuthCode => params[:AuthCode],
        :responseTimeStamp => params[:responseTimeStamp],
        :messgae => params[:message],
        :Reason => params[:Reason],
        :ReasonCode => params[:ReasonCode],
        :ppp_status => params[:ppp_status],
        :PPP_TransactionID => params[:PPP_TransactionID],
        :client_ip => params[:client_ip],
        :cardNumber => params[:cardNumber],
        :uniqueCC => params[:uniqueCC]
    )
    
  end

  # This Token is generated following the PPP return, since DMN may take 30-60 min some times to retutn.
  def create_temporary_token!(params)

    self.tokens.create!( 
        :status => params[:Status],
        :CCToken => params[:Token],
        :PPP_TransactionID => params[:PPP_TransactionID],
        :Reason => 'PPP Callback'
    )
    
  end

  def registered?  #ToDo: set an instance variable for performance
    self.tokens.any?
  end
  
  def registered_or_waived
    unless Paykido::Application.config.rules_require_registration
      true
    else
      self.registered?
    end
  end
  
  def token
    self.tokens.first if self.tokens.any?
  end
  
  def request_confirmation(consumer)     

    begin
      UserMailer.delay.consumer_confirmation_email(self, consumer)
    rescue
      return false
    end

    begin
      message = "Hi #{self.name}! #{consumer.name} asked us to tell you about Paykido. See our email for details"
      Sms.send(self.phone, message)
    rescue
      return false
    end
    
  end 





end
