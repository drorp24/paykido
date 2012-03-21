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
    
    get_purchase_parameters
    find_or_create_consumer
    find_payer
    login_messages        
    
  end
  

  def login_callback
    
    login
    
    respond_to do |format|   
      format.js  
    end   
    
  end
  

  def get_purchase_parameters
    
    session[:retailer] = 'zynga'          # check it exists in the retailer table   
    session[:title] = 'farmville'         # check it exists in the title table
    
    if params[:product]
      @product = params[:product].split('@')[0]
    elsif params[:desc]     
      @product = params[:desc]
    else
      @product = session[:product]
    end
    session[:product] = @product
     
    if params[:product]
      @price = params[:product].split('@')[1]
    elsif params[:amount]
      @price = params[:amount]
    else
      @price = session[:price]
    end
    session[:price] = @price
            
  end  
  

  def find_or_create_consumer
    
    begin
      if current_facebook_user
        @consumer = find_or_create_consumer_by_facebook_user
      else
        @consumer = session[:consumer] = nil 
      end 
    rescue Mogli::Client::OAuthException
        @consumer = session[:consumer] = nil 
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
  
  def find_payer
    @payer = session[:payer] = @consumer.payer unless @consumer.nil?
  end
  
  def login_messages
    
    if @consumer     
      @salutation = "Welcome "
      @name = @consumer.name + "!"  
      @pic = "https://graph.facebook.com/#{@consumer.facebook_id}/picture"
      
      @first_line = "You're about to buy"
      @second_line = "#{@product} for $#{@price}"
    else
      @salutation = "Hello!"
      @name = nil
      @pic = nil
      @first_line =  "You selected #{session[:product]} for #{session[:price]}"
      @second_line = "Login or register, and get it in one click"
    end
    
  end      
    
   
  #############################################
  #############################################
  

  
  def register_callback # try making it ajax instead of attempting to redirect (looks like facebook doesnt allow) 
      
    find_or_create_consumer_and_payer     
    request_joinin(@payer, @consumer)    
    
   session[:friend_authenticated] = true 
   redirect_to :controller => :play, :action => :index
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

  #############################################
  #############################################
 
    
  def buy
    
#    begin 
           
      @purchase = session[:purchase] = 
      Purchase.create_new!(session[:payer], session[:consumer], session[:retailer], session[:title], session[:product], session[:price])
                                          
      @purchase.authorize!
      if @purchase.authorized?                        # and @purchase.paid? (succesfully)?
#       pay_retailer                                  # @purchase.pay!
        @purchase.account_for!                        # if payment was succesful!       
      elsif @purchase.requires_manual_approval?
        request_approval(@purchase)                   #replace with purchase.request_approval - no need for any param then
      end
      authorization_messages      
    
    respond_to do |format|  
      format.html {  }  
      format.js  
    end
    
  end
  

  def authorization_messages
    
     if     @purchase.authorized
      @first_line = "#{session[:product]} is yours!"
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
          @second_line = "Balance is too low ($#{@purchase.consumer.balance})."
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
  
  def request_approval(purchase)
    
    begin
      UserMailer.approval_email(purchase).deliver
    rescue
      @email_problem = true
    else
      @email_problem = false
    end
      
    message = "Hi from Paykido! #{purchase.consumer.name} asks that you approve #{purchase.product} from #{purchase.retailer.name}. See our email for details"
    sms(purchase.payer.phone, message) 
    
  end
  
    def request_joinin(payer, consumer)
     
    begin
      UserMailer.joinin_email(payer, consumer).deliver
    rescue
      @email_problem = true
    else
      @email_problem = false
    end

    message = "Hi #{payer.name}! #{consumer.name} asked us to tell you about Paykido. See our email for details"
    sms(payer.phone, message) 
    
  end 
  
  private
  
  def ensure_friend_authenticated    
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
      
end
