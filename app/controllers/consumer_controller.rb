require 'rubygems'
require 'clickatell'
class Safecharge
  include HTTParty
  base_uri 'https://test.safecharge.com'
  format :xml
end


class ConsumerController < ApplicationController
  
  #  before_filter :ensure_friend_authenticated
  #  before_filter :ensure_consumer_authenticated, :except => ["login", "register", "register_callback"]
    
  
  
  def login
    
    find_product
    find_or_create_consumer
    find_payer_and_user
    login_messages        
    
  end
  

  def login_callback
    
    login
    
    respond_to do |format|   
      format.js  
    end   
    
  end
  

  def find_product
    
    if params[:product]
      @product_title = params[:product].split('@')[0]
    elsif params[:desc]     
      @product_title = params[:desc]
    else
      @product_title = session[:product_title]
    end
    session[:product_title] = @product_title
     
    if params[:product]
      @product_price = params[:product].split('@')[1]
    elsif params[:amount]
      @product_price = params[:amount]
    else
      @product_price = session[:product_price]
    end
    session[:product_price] = @product_price
        
  end  
  

  def find_or_create_consumer
    
    if current_facebook_user
      @consumer = find_or_create_consumer_by_facebook_user
    else
      @consumer = nil 
      clear_session
   end    
    
  end
  

  def find_or_create_consumer_by_facebook_user
    
    @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)
    @consumer.name = @consumer.facebook_user.first_name
    @consumer.pic =  @consumer.facebook_user.large_image_url
    @consumer.tinypic = @consumer.facebook_user.image_url
    @consumer.save!
    
    session[:consumer] = @consumer
    
  end
  
  def find_payer_and_user 
    
    unless @consumer.nil?
      @payer = session[:payer] = @consumer.payer
      @user = session[:user] = (@consumer.payer_id) ?(User.where("payer_id = ? and email IS NOT NULL", @consumer.payer_id).first) :nil
    end
  end
  
  def login_messages
    
    if @consumer     
      @salutation = "Welcome "
      @name = @consumer.name + "!"  
      @pic = "https://graph.facebook.com/#{@consumer.facebook_id}/picture"
      
      @first_line = "You're about to buy"
      @second_line = "#{@product_title} for $#{@product_price}"
    else
      @salutation = "Hello!"
      @name = nil
      @pic = nil
      @first_line =  "You have selected #{@product_title}"
      @second_line = "Login or register, and get it in one click"
    end
    
  end    


  def clear_session
    session[:consumer]= session[:payer]= session[:retailer]=
    session[:product]= session[:products] = 
    #      session[:product_title] = session[:product_price] =
    session[:purchase]=
    session[:current_facebook_user_id] = session[:current_facebook_access_token] =
    session[:activity] = session[:last_scroll] =
    nil
  end
  
    
   
  #############################################
  #############################################
  

  
  def register_callback # try making it ajax instead of attempting to redirect 
      
    find_or_create_consumer_and_payer     
    find_or_create_user
    request_joinin(@user, @consumer)    
    
   session[:friend_authenticated] = true 
    redirect_to :controller => :play, 
                :action => :index
# find out later why: all session is being erased
# perhaps the save state doesnt escape the url
#                , 
#                :scroll => session[:last_scroll], 
#                :product => session[:product_title] + '@' + session[:product_price], 
#                :sms => @sms
    
  end
  
  
  def find_or_create_consumer_and_payer
    
    # A consumer record may exist already (e.g., he registered already, and later unregistered thru facebook)
    # A payer record may already be linked with such consumer (e.g. in the case above)
    # A payer record may exist in the system with that email specified in the registration form
    # (e.g., the parent has subscribed already and this is the next brother registering)
    
    if facebook_params_user_id = facebook_params['user_id']
      @consumer = Consumer.find_or_initialize_by_facebook_id(facebook_params_user_id)   
    elsif current_facebook_user #probably never true for some reason
      @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)
    else # this shouldn't happen 
      @consumer = session[:consumer] || Consumer.new
    end 
    
    @payer = @consumer.payer || Payer.find_or_initialize_by_email(facebook_params['registration']['payer_email'])
    @payer.update_attributes!(
          :name => facebook_params['registration']['payer_name'], 
          :email => facebook_params['registration']['payer_email'], 
          :phone => facebook_params['registration']['payer_phone'])    

    @consumer.update_attributes!(
          :name => facebook_params['registration']['name'].split(' ')[0],
          :payer_id => @payer.id, 
          :billing_phone => facebook_params['registration']['consumer_phone'],
          :pic =>  "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture?type=large",
          :tinypic => "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture")
   

    session[:consumer] = @consumer
    session[:payer] =    @payer
    
  end 

  def find_or_create_user
    
    @user = User.find_by_email(facebook_params['registration']['payer_email'])
    if @user
      @user.update_attributes!(:payer_id => session[:payer].id, :name => facebook_params['registration']['payer_name'])   #just to be on the safe side
      session[:user] = @user
    else
      create_new_user      
    end
    return if @user_failed

  end
  
    
  #############################################
  #############################################
 
    
  def buy
    
    find_all
    
    unless @consumer 
      @first_line =  "Please login or register"
      @second_line = "to buy with paykido 1-click!"
      return
    end
        
    begin      
      create_purchase
      authorize_purchase
#     pay_retailer
      if @purchase.authorized? # and retailer_paid (succesfully)?
        account_for(@purchase)
      elsif @purchase.requires_manual_approval?
        request_approval(@user, @consumer, @purchase) 
      end
      authorization_messages      
    rescue
      @first_line = "Your online connection is lost"
      @second_line = "Please try again later"
      raise
    end    
    
    respond_to do |format|  
      format.html {  }  
      format.js  
    end
    
  end
  

  def find_all

    @consumer = session[:consumer]
    @payer = session[:payer]
    @user = session[:user]
    # currently, retailer = Zynga. When invoked thru API the retailer name will be part of the API paramters.
    @retailer = Retailer.find(1)
    @product = Product.find_or_initialize_by_title_and_price(session[:product_title], session[:product_price])
    # there should be a mapping from product -> category
    @product.update_attributes!(:category_id => 6) unless @product.id  
    
    session[:retailer] = @retailer
    session[:product] = @product 
    
  end
  

  def create_purchase
    
    @purchase = @payer.purchases.create(:consumer_id => @consumer.id, 
                                        :payer_id => @payer.id, 
                                        :retailer_id => @retailer.id, 
                                        :product_id => @product.id, 
                                        :category_id => 1,
                                        :amount => @product.price, 
                                        :date => Time.now, 
                                        :location => generate_location)
    session[:purchase] = @purchase       
   
  end
  

  def generate_location
  # created to demo the Publisher app    
    r = rand
    if r < 0.33
      location = "China"
    elsif r < 0.66
      location = "Israel"
    else
      location = "US"
    end
    
  end  
  

  def authorize_purchase  
       
    if @purchase.product.blacklisted?(@payer.id, @consumer.id) 
      @purchase.authorization_type = "Unauthorized Product"
      @purchase.authorized = false      
    elsif @purchase.retailer.blacklisted?(@payer.id, @consumer.id) 
      @purchase.authorization_type = "Unauthorized retailer"
      @purchase.authorized = false      
    elsif @purchase.product.category.blacklisted?(@payer.id, @consumer.id) 
      @purchase.authorization_type = "Unauthorized Category"
      @purchase.authorized = false      
      
    elsif !@consumer.balance or @consumer.balance <= 0
      @purchase.authorization_type = "Zero Balance"
      @purchase.authorized = false      
    elsif @consumer.balance < @purchase.amount
      @purchase.authorization_type = "Insufficient Balance"
      @purchase.authorized = false
      
    elsif @purchase.amount <= @consumer.auto_authorize_under
      @purchase.authorization_type = "Under Threshold"
      @purchase.authorized = true
    elsif @purchase.amount > @consumer.auto_deny_over
      @purchase.authorization_type = "Over Threshold"
      @purchase.authorized = false
      
    elsif @purchase.manually_authorized?
      @purchase.authorized = true
    else
      @purchase.require_manual_approval
      @purchase.authorized = false
    end
    
    @purchase.authorization_date = Time.now
    @purchase.save!
    
  end  
  

  def pay_retailer     # choose which gw to use
    
    retailer_paid = true if safecharge_gw == "APPROVED"
     
  end

  def paypal_gw
    
    pay_request = PaypalAdaptive::Request.new
    
    data = {
    "returnUrl" => "",
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=>"USD",
    "cancelUrl"=>"",
    "senderEmail" => "drorp1_1297098617_per@yahoo.com",
    "receiverList"=>{"receiver"=>
        [{"email"=>"drorp2_1297098512_biz@yahoo.com", "amount"=>""}]},
    "actionType"=>"PAY",
    "trackingId" => "",
    "preapprovalKey" => session[:preapprovalKey],
    "ipnNotificationUrl"=>""    }
    
    pay_response = pay_request.pay(data)
    
    if pay_response.success?
      flash[:message] = "Thank you!"
      @retailer_paid = true
      redirect_to ""
    else
      puts pay_response.errors.first['message']
      flash[:message] = pay_response.errors.first['message']
      retailer_paid = false
      redirect_to ""
    end    
    
  end 
  
  def safecharge_gw
        
    sg_NameOnCard = "John Smith"
    sg_CardNumber = "1234567812345678"
    sg_ExpMonth = "12"
    sg_ExpYear = "24"
    sg_CVV2 = "123"
    sg_TransType = "Sale"
    sg_Currency = "USD"
    sg_Amount = @product.price.to_s
    sg_ClientLoginID = "Paykido_TRX"
    sg_ClientPassword = "password"
    sg_ResponseFormat = "4"
    sg_FirstName = @payer.name
    sg_LastName = @payer.family || "Smith"
    sg_Address = "1000 Pine Grove"
    sg_City = "Milpitas"
    sg_Zip = "92535"
    sg_Country = "US"
    sg_Phone = "2131234567"
    sg_IPAddress = request.remote_ip
    sg_Email = @payer.email || "johnsmith@yahoo.com"
    
    gw = Safecharge.get('/service.asmx/Process', :query => {
     :sg_NameOnCard => sg_NameOnCard,
     :sg_CardNumber => sg_CardNumber, 
     :sg_ExpMonth => sg_ExpMonth,
     :sg_ExpYear => sg_ExpYear,
     :sg_CVV2 => sg_CVV2, 
     :sg_TransType => sg_TransType, 
     :sg_Currency => sg_Currency, 
     :sg_Amount => sg_Amount, 
     :sg_ClientLoginID => sg_ClientLoginID, 
     :sg_ClientPassword => sg_ClientPassword,
     :sg_ResponseFormat => sg_ResponseFormat,
     :sg_FirstName => sg_FirstName,
     :sg_LastName => sg_LastName,
     :sg_Address => sg_Address,
     :sg_City => sg_City,
     :sg_Zip => sg_Zip,
     :sg_Country => sg_Country,
     :sg_Phone => sg_Phone,
     :sg_IPAddress => sg_IPAddress,
     :sg_Email => sg_Email     
     })
     
     @gw_reason = gw[:Response][:Reason]
     @gw_status = gw[:Response][:Status]
    
  end
  
  def account_for(purchase)
    
    amount = purchase.amount
  
    @retailer = session[:retailer] 
    @retailer.record(amount)
    @retailer.save!
    session[:retailer] = @retailer
    
    @consumer = session[:consumer]
    @consumer.record(amount)
    @consumer.save!
    session[:consumer] = @consumer
   
  end


  def authorization_messages
    
     if     @purchase.authorized
      @first_line = "#{session[:product_title]} is yours!"
      @second_line = "Thanks for using paykido!"
     elsif  @purchase.requires_manual_approval?
       if @email_problem
          @first_line =  "Approval reuiqred but email is down at the moment"
          @second_line = "Please try again in a few moments"
       else  
        @first_line =  "This has to be manually authorized"
        @second_line = "Approval request has been sent"
       end
     elsif !@purchase.authorized 
        @first_line = "This purchase is unauthorized"
        if @purchase.authorization_type == 'Insufficient Balance'
          @second_line = "Balance is too low ($#{@consumer.balance})."
        else
          @second_line = "#{@purchase.authorization_type}"
        end      
#    elsif !retailer_paid?
#     @first_line =  "[retailer was not paid message]"
#     @second_line = "[retailer was not paid message]"      
     else
      @first_line = "Paykido is momentarily down"
      @second_line = "Please try again soon"     
    end  
    
  end  
  
  def request_approval(user, consumer, purchase)
    
    begin
      user = User.find(108)
      UserMailer.approval_email(user, consumer, purchase).deliver
    rescue
      @email_problem = true
    else
      @email_problem = false
    end
      
    message = "Hi from Paykido! #{purchase.consumer.name} asks that you approve #{purchase.product.title} from #{purchase.retailer.name}. See our email for details"
    sms(purchase.payer.phone, message) 
    
  end
  
    def request_joinin(user, consumer)
     
    begin
      UserMailer.joinin_email(user, consumer).deliver
    rescue
      @email_problem = true
    else
      @email_problem = false
    end

    message = "Hi #{user.payer.name}! #{consumer.name} asked us to tell you about Paykido. See our email for details"
    sms(user.payer.phone, message) 
    
  end 
  
  private
  
  def ensure_friend_authenticated    
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  
  
  def create_new_user
    
    @user = User.new

    @user.email = session[:payer].email
    @user.name = session[:payer].name
#    @user.password = generate_string
    @user.password = "1"
    @user.affiliation = "payer"
    @user.role = "primary"
    @user.payer_id = session[:payer].id

    if @user.save
      session[:user] = @user
    else
      @user_failed = true
    end
        
  end
  
  def generate_string(length=6)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    string = ''
    length.times { |i| string << chars[rand(chars.length)] }
    string
  end
  
end
