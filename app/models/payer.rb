require 'digest/sha1'                           # remove once Devise is in

class Payer < ActiveRecord::Base

  has_many  :consumers
  has_many  :purchases
  has_many  :rules                              # family-default rules (as opposed to consumer rules)
  has_many  :registrations
  has_many  :notifications
  
   
  attr_accessor :password_confirmation          # remove once Devise is in
  
  def g2spp
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
      "&merchantLocale=" + I18n.locale.to_s + "&" +
      "checksum=" + self.checksum(time_stamp, item_name) + test_fields
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


  def create_registration!(params)
    self.registrations.create!( 
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

  def registered?
    self.registrations.any?
  end
  
  def registration
    self.registrations.first if self.registrations.any?
  end
  
  def request_confirmation(consumer)     

    begin
      UserMailer.consumer_confirmation_email(self, consumer).deliver
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


  ##############################################
  # remove all the following once Devise is in #
  ##############################################

  def self.authenticate(email, password)
    payer = self.find_by_email(email)
    if payer
      return nil unless payer.salt
      expected_password = encrypted_password(password, payer.salt)
      if payer.hashed_password != expected_password
        payer = nil
      end
    end
    payer
  end
  
  def self.authenticate_by_token(email, hash)     
    payer = self.find_by_email_and_hashed_password(email, hash)
  end
    
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Payer.encrypted_password(self.password, self.salt)
  end
  
  def remember_me       
    @remember_me
  end
  
  def remember_me=(rm)
    
  end

private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end