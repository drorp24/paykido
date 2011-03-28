require 'rubygems'
require 'clickatell'


class ConsumerController < ApplicationController
  
#  before_filter :ensure_friend_authenticated
#  before_filter :ensure_consumer_authenticated, :except => ["login", "register", "register_callback"]
  
  
  def logout
    
  end
  
  def pay
    
    pay_request = PaypalAdaptive::Request.new

    data = {
    "returnUrl" => "http://www.go-arca.com/subscriber/payer_signedin",
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=>"USD",
    "cancelUrl"=>"http://www.go-arca.com/subscriber/payer_signedin",
    "senderEmail" => "drorp1_1297098617_per@yahoo.com",
    "receiverList"=>{"receiver"=>
         [{"email"=>"drorp2_1297098512_biz@yahoo.com", "amount"=>"1499.00"}]},
    "actionType"=>"PAY",
    "trackingId" => "191",
    "preapprovalKey" => session[:preapprovalKey],
    "ipnNotificationUrl"=>"http://www.go-arca.com/subscriber/ipn_notification"    }
    
    pay_response = pay_request.pay(data)
    
    if pay_response.success?
      flash[:message] = "Thank you!"
      redirect_to "/subscriber/payer_signedin"
    else
      puts pay_response.errors.first['message']
      flash[:message] = pay_response.errors.first['message']
      redirect_to "/subscriber/payer_signedin"
    end    
    
  end
  
 # def buy_window
    
#    if current_facebook_user
#       session[:current_facebook_user_id] = current_facebook_user.id
#       consumer = Consumer.find_by_facebook_id(session[:current_facebook_user_id])
#       @consumer_name = consumer.name if consumer
#       if consumer and consumer.payer.registered?
#         @consumer_status = "registered"
#       else
#         @consumer_status = "logged_in"
#       end
#    else
#       @consumer_status = "not_logged_in"
#    end
    
#    @products = session[:products] || Product.find_product_options(1)
#    session[:products] = @products

#    session[:product_title] = params[:amountdesc] || session[:product_title]
#    session[:product_price] = params[:amount] || session[:product_price]

#    find_consumer    
#    login_messages
    
#  end
  
  def login
    
    session[:product_title] = params[:product].split('@')[0] || session[:product_title]
    session[:product_price] = params[:product].split('@')[1]  || session[:product_price]

    find_consumer
    login_messages        
    
  end
  
  def login_callback
    
    login
    
    respond_to do |format|  
       format.html  
       format.js  
     end

    
  end

  
  def find_consumer
    
    if current_facebook_user
      @consumer = find_consumer_by_facebook_user
    else
      @consumer = nil 
      clear_session
    end    

  end

  def login_messages
    
    if @consumer
      @salutation = "Welcome "
      @name = @consumer.name + "!"  
      @pic = "https://graph.facebook.com/#{@consumer.facebook_id}/picture"
      @first_line = "You have selected"
      @second_line = "#{session[:product_title]} for $#{session[:product_price]}"
    else
      @salutation = "Hello!"
      @name = nil
      @pic = nil
      @first_line =  "Register to arca"
      @second_line = "and buy in one click!"
    end
    
  end    
  
  def find_consumer_by_facebook_user
    
    @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)    
    session[:consumer] = @consumer

    @payer = session[:payer] = @consumer.payer if @consumer    
    @consumer_rule = session[:consumer_rule] = @consumer.most_recent_payer_rule if @consumer
    


#    begin
#    @consumer.update_attributes(:name => @consumer.facebook_user.first_name,
#                                :pic => @consumer.facebook_user.large_image_url,
#                                :tinypic => @consumer.facebook_user.image_url)
                                 
#    rescue @first_line = "(tmp) access token problem"
#    end
    
    @consumer
  
  end

  
 # def register
    
 #   session[:activity] = "register"
 #   redirect_to :controller => :play, :action => :index
    
 # end
  
#  def register_window

#    if current_facebook_user
#      session[:current_facebook_user_id] = current_facebook_user.id
#      consumer = Consumer.find_by_facebook_id(session[:current_facebook_user_id]) 
#    else
#      flash[:notice] = "FB login failed"
#      return
#    end
    
#    if consumer and consumer.facebook_id and consumer.payer.registered? 
#      redirect_to :action => :buy
#    end
        
#  end
      
  def register_callback

  # Every consumer in the sysetm is registered and so its connected payer.
  # A consumer record may exist already (e.g., registered and later removed arca from his facebook app list)
  # if parent's phone number exists already, then an existing payer record will be used instead of a new payer created
  # whether for first consumer in the family or any next one, payer will always get an sms and code to enter acct    

    
    create_consumer_and_payer 

    # send SMS/email to parent. 
    # Need to check consumer's and payer's phone validity thru facebook registration

    session[:activity] = "buy"
    redirect_to :controller => :play, :action => "index", :scroll => session[:last_scroll]

    
  end
 

  # check whether payer exists already:
  #   (consumer already asked his parent to register but that has not yet happened; or consumer now updates phone num)
  #       if consumer record exists and linked to a payer recrod, then update that payer record and dont create a new one
  #   (parent has already registered, e.g., by the consumer's brother. 
  #       find if a payer exists that has that given phone then link consumer to that payer record. 
  #   (first consumer in this family)
  #       If none of the above, initialize a new record then update as above.

  def create_consumer_and_payer

    current_facebook_user_id = current_facebook_user.id
    current_facebook_access_token = current_facebook_client.access_token

    @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user_id)
    @payer = @consumer.payer || Payer.find_or_initialize_by_phone(facebook_params['registration']['payer_phone'])
    @payer.update_attributes!(:exists => true, :email => facebook_params['registration']['payer_email'], :family => @consumer.facebook_user.last_name)    
    @consumer.update_attributes!(:facebook_id => current_facebook_user_id, 
                                 :facebook_access_token => current_facebook_access_token,
                                 :name => @consumer.facebook_user.first_name,
                                 :pic => @consumer.facebook_user.large_image_url,
                                 :tinypic => @consumer.facebook_user.image_url,
                                 :payer_id => @payer.id, 
                                 :balance => 50, 
                                 :billing_phone => facebook_params['registration']['consumer_phone'])
    update_consumer_rule

    session[:consumer]   =  @consumer
    session[:consumer_rule] =  @consumer_rule
    session[:payer]      =  @payer
    session[:facebook_id] = @consumer.facebook_id
     
  end

  def update_consumer_rule    
    unless @consumer_rule = @consumer.most_recent_payer_rule
      find_def_consumer_rule
      @consumer_rule = @consumer.payer_rules.create!(:allowance => @def_consumer_rule.allowance, :rollover => @def_consumer_rule.rollover, :auto_authorize_under => @def_consumer_rule.auto_authorize_under, :auto_deny_over => @def_consumer_rule.auto_deny_over)     
    end
  end

  def find_def_consumer_rule        
    @def_consumer_rule = PayerRule.find_by_payer_id(@payer.id) if @payer and @payer.id    
    @def_consumer_rule ||= PayerRule.new(:allowance => 50, :rollover => false, :auto_authorize_under => 10, :auto_deny_over => 25)   
    @def_allowance = @def_consumer_rule.allowance
  end
  
  def save_scroll
    
    session[:last_scroll] = params[:id]    
    respond_to do |format|  
      format.html { redirect_to "zzz" }  
      format.js  
    end
    
  end
  

#  def select_product

#    session[:product] = Product.find(params[:product][:id])
#    session[:product_title] = session[:product].title
#    session[:product_price] = session[:product].price
#    session[:retailer_name] = "Zynga"
#    @first_line = "You have selected " + session[:product].title

#    respond_to do |format|  
#      format.html { redirect_to "hbatuna" }  
#      format.js  
#    end 

    
#  end
  
#  def set_session  

  # If no product was selected first, no use to do anything. This will be found in no_use_waiting, which is next.  
#    if session[:product].nil?
#      @no_product_selected = true
#      return
#    end

  # We can therefore assume that the following must be set by now
#    @product = session[:product]
#    @product_title = session[:product_title]
#    @product_price = session[:product_price]
#    @retailer_name = "Zynga"
    
  # We clear the product session, to force passing thru the product selection next time too
  # For the rest of that call, we should use only @ product variables, not session ones
#    session[:product] = session[:product_title] = session[:product_price] = nil
    

  # if the phone in the parameters matches the prev one, and the product matches the prev purchase, then we assume it's the same session:
  # that means we're expecting the same pin, or still waiting, or no use waiting, or just about to complete the process now. 
  # However, if it differs, we clear the session

#    last_purchase = Purchase.find_by_id(session[:purchase_id]) if session[:purchase_id]
    
#    if last_purchase and 
#       current_facebook_user.id == session[:facebook_id] and
#       @product.id == last_purchase.product_id  
 
#       @consumer = session[:consumer]
#       @purchase = Purchase.find(session[:purchase_id]) 

#    else

#       clear_session
#       @consumer = Consumer.find_by_facebook_id(current_facebook_user.id)
#       session[:consumer] = @consumer

#    end
     
#   end
         
  
   def clear_session
  # find a better command to clear out all session construct
      session[:consumer]= session[:consumer_rule] = session[:payer]= session[:retailer]=
      session[:product]= session[:products] = session[:product_title] = session[:product_price] =
      session[:purchase]=
      session[:current_facebook_user_id] = session[:current_facebook_access_token] =
      session[:activity] = session[:last_scroll] =
#      session[:expected_pin]=      
      nil
   end
    

#  def no_use_waiting
    
#    if @no_product_selected
#      @first_line = "Please select product first"
#      @second_line = "Then try again"
#      true

#    elsif @consumer.invalid? 
#      @first_line = "Wrong phone number"
#      @second_line = "Please try again"
#      true
      
#     if session[:purchase]
       
#        if @purchase.authorization_type == "PendingPayer"
#          @first_line = "Please hold while this purchase is being approved"
#          @second_line = ""
#          true
#        elsif !@purchase.authorized and @purchase.authorization_type
#          @first_line = "We're sorry. This purchase was unauthorized"
#          @second_line = ""
#          true
#        elsif @purchase.authorized
#          @first_line = "Your purchase has been approved!"
#          @second_line = "Go ahead and enter the PIN code now"
#          true
#        else
#          false
#        end
      
#    else
#      nil
#    end 
    
#  end
  
  def buy
    
#  set_session

#  unless no_use_waiting


    unless @consumer = session[:consumer]
      @first_line =  "Please login and register"
      @second_line = "to buy with arca 1-click!"
      return
    end
      
    begin

      find_consumer_and_payer
      find_retailer_and_product
      find_or_create_purchase
      authorize_purchase
#      authenticate_consumer
      account_for(@purchase.amount) if @purchase.authorized?
      authorization_messages

    rescue
      @first_line = "Your online connection is lost"
      @second_line = "Please try again later"
      raise
     end
    
#  end


     respond_to do |format|  
       format.html { redirect_to :action => 'zzz' }  
       format.js  
     end
  
  end

  def find_consumer_and_payer

     @consumer = session[:consumer]
     @payer = session[:payer]
     @consumer_rule = session[:consumer_rule]
     
  end



#  def authenticate_consumer
    
#    if @consumer.pin?
      
#      @purchase.authentication_type = "PIN"
#      session[:expected_pin] = @consumer.pin
      
#    elsif @purchase.authorized?
      
#      @purchase.authentication_type = "SMS"
#      session[:expected_pin] = rand.to_s.last(4)
#      send_sms_to_consumer
      
#    else
#      @purchase.authentication_type = "SMS"
#      session[:expected_pin] = rand.to_s.last(4)
      
#    end 
    
#    @purchase.expected_pin = session[:expected_pin] # unless @sms_failed

#  end

  def authorization_messages
    
#    if @sms_failed
#      @first_line = "Couldn't locate that phone."
#      @second_line = "Please check the number and try again"
    if @purchase.authorization_type == "PendingPayer" 
      @first_line =  "This has to be manually authorized"
      @second_line = "We'll text you as soon as it is over!"
    elsif !@purchase.authorized 
      @first_line = "This purchase is unauthorized"
      if @purchase.authorization_type == 'Insufficient Balance'
        @second_line = "Your balance is too low ($#{@consumer.balance})."
      else
        @second_line = "#{@purchase.authorization_type}"
      end

#    elsif !@purchase.authorized
#      @first_line = "We're sorry. This purchase is unauthorized..."
#      @second_line = ""
#   elsif @purchase.authorized and @purchase.authentication_type == "PIN"
#      @first_line = "Welcome back!"
#      @second_line = "Go ahead and key in your permanent PIN"
#    elsif @purchase.authorized and @purchase.authentication_type == "SMS"
#      if Current.policy.online? and Current.policy.send_sms?
#        @first_line = "Thank you. An SMS is on its way."
#      else
#        @first_line = "No SMS sent - you are offline"
#      end      
   elsif @purchase.authorized
#      if Current.policy.online? and Current.policy.send_sms?
#        @first_line = "Thanks... An SMS is on its way."
#      else
#        @first_line = "Thanks... No SMS - you are offline"
#      end      
#      @second_line = "Subscribe and get it with no SMS!"
      @first_line = "#{session[:product_title]} is yours!"
      @second_line = "Thanks for using arca"
    else
      @first_line = "Arca is momentarily down."
      @second_line = "Please try again in a few moments."
      
    end  
 
  end

#  def authenticate
    
# First try to match the keyed pin to the session's purchase' expected pin. This is the most common case.
# But if it doesnt match, look for the keyed pin in another purchase of the same subscriber with a BLANK AUTHENTICATION DATE
    
#    begin
      
# First, find which purchase the user is responding to (he might have gotten several sms's with different purchases)
#    @purchase = Purchase.find(session[:purchase_id]) if session[:purchase_id]

#    unless @purchase and @purchase.authorized? and !@purchase.authentication_date and (params[:pin]== @purchase.expected_pin or params[:pin] == session[:expected_pin])
#      @another_purchase = 
#        Purchase.find_by_consumer_id_and_expected_pin(session[:consumer].id, params[:pin],
#        :conditions => ["authentication_date is ? and authorized = ?", nil, true])
#      @purchase = @another_purchase if @another_purchase
#    end
    
#    expected_pin = @purchase.expected_pin if @purchase 
#    expected_pin = expected_pin || session[:expected_pin] 

#    if @purchase
#      if @purchase.authorized? and @purchase.authorization_type != "PendingPayer" and @purchase.authentication_date == nil and params[:pin]== expected_pin
#        @first_line = "Purchase of #{@purchase.product.title} is approved!"
#        @second_line = "Thanks for shopping with arca"
#        @purchase.authentication_date = Time.now
#        save_purchase
#        account(@purchase.amount)
#        clear_session
#      elsif @purchase.authorized? and @purchase.authorization_type != "PendingPayer" and @purchase.authentication_date == nil and params[:pin] != expected_pin
#        @first_line = "Wrong PIN entered (#{expected_pin})"
#        @second_line = "Please try again"
#      elsif !@purchase.authorized? and @purchase.authorization_type == "PendingPayer"
#        @first_line = "This purchase has yet to be authorized"
#        @second_line = "Please hold on til you get the text message"
#      elsif !@purchase.authorized? and @purchase.authorization_type == "Unauthorized"
#        @first_line = "We're sorry. This purchase was not authorized"
#        @second_line = ""     
#        clear_session
#      else

#        @first_line = "Wrong PIN entered..."
#        @second_line = "Please try again"        
#      end
#    else
#        @first_line = "You need to get authorization first"
#        @second_line = "Complete step 1 then try again"
#    end

#    rescue 
#      @first_line = "Service is temporarily down"
#      @second_line = "Please hold on for a few moments"
#      raise
#    end
  
#  end

   
  def find_retailer_and_product
    @retailer = Retailer.find(1)
    @product = Product.find_or_initialize_by_title_and_price(session[:product_title], session[:product_price])
#    Product.update(@product.id, :category_id => 6)     nothing works, no way to save @product 
#### WACKO CODE
    unless @product.category_id == 6
      product_clone = @product.clone
      product_clone.id = @product.id
      product_clone.category_id = 6
      product_clone.updated_at = Time.now
      @product.delete
      product_clone.save
      @product = product_clone
    end
#### WACKO CODE
 
    session[:retailer] = @retailer
    session[:product] = @product
  end
    

  def find_or_create_purchase
    
#     if session[:purchase_id]
#       @purchase = Purchase.find(session[:purchase_id])
#     else
       @purchase = @payer.purchases.create(:consumer_id => @consumer.id, :payer_id => @payer.id, :retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now, :location => generate_location)
       session[:purchase] = @purchase       
#     end
   
  end
 
  def generate_location
    
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
    
    
      @consumer = session[:consumer]
      @rule = session[:consumer_rule]
      @purchase.authorized = false                            
    
      if @purchase.product.is_blacklisted(@payer.id) 
        @purchase.authorization_type = "Unauthorized Product (#{@purchase.product.title})"
        @purchase.authorized = false      
      elsif @purchase.retailer.is_blacklisted(@payer.id) 
        @purchase.authorization_type = "Unauthorized Merchant (#{@purchase.retailer.name})"
        @purchase.authorized = false      
      elsif @purchase.product.category.is_blacklisted(@payer.id) 
        @purchase.authorization_type = "Unauthorized Category (#{@purchase.product.category.name})"
        @purchase.authorized = false      
      
      elsif @consumer.balance <= 0
        @purchase.authorization_type = "Zero Balance"
        @purchase.authorized = false      
      elsif @consumer.balance < @purchase.amount
        @purchase.authorization_type = "Insufficient Balance"
        @purchase.authorized = false
        
      elsif @purchase.amount <= @rule.auto_authorize_under
        @purchase.authorization_type = "Under Threshold"
        @purchase.authorized = true
      elsif @purchase.amount > @rule.auto_deny_over
        @purchase.authorization_type = "Over Threshold"
        @purchase.authorized = false
             
      elsif @purchase.authorization_type == "ManuallyAuthorized"
        @purchase.authorized = true
      else
        @purchase.authorization_type = "PendingPayer"
        @purchase.authorized = false
      end
        
      @purchase.authorization_date = Time.now
      @purchase.save!
    
  end
  
#  def save_purchase
    
#    if @purchase.save
#        File.delete("#{RAILS_ROOT}/public/service/purchases/all.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/all.js")
#        File.delete("#{RAILS_ROOT}/public/service/purchases/consumer_#{@purchase.consumer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/consumer_#{@purchase.consumer_id}.js")
#        File.delete("#{RAILS_ROOT}/public/service/purchases/retailer_#{@purchase.retailer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/retailer_#{@purchase.retailer_id}.js")
#        File.delete("#{RAILS_ROOT}/public/service/purchases/product_#{@purchase.product_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/product_#{@purchase.product_id}.js")
#        File.delete("#{RAILS_ROOT}/public/service/purchases/category_#{@purchase.product.category_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/category_#{@purchase.product.category_id}.js")

#        if @purchase.authentication_date?
#          File.delete("#{RAILS_ROOT}/public/service/consumers/0.js") if File.exist?("#{RAILS_ROOT}/public/service/consumers/0.js")
#          File.delete("#{RAILS_ROOT}/public/service/consumer/#{@purchase.consumer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/consumer/#{@purchase.consumer_id}.js")
#          File.delete("#{RAILS_ROOT}/public/service/retailers.js") if File.exist?("#{RAILS_ROOT}/public/service/retailers.js")
#          File.delete("#{RAILS_ROOT}/public/service/products.js") if File.exist?("#{RAILS_ROOT}/public/service/products.js")
#          File.delete("#{RAILS_ROOT}/public/service/categories.js") if File.exist?("#{RAILS_ROOT}/public/service/categories.js")
#          File.delete("#{RAILS_ROOT}/public/service/retailer/#{@purchase.retailer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/retailer/#{@purchase.retailer_id}.js")
#          File.delete("#{RAILS_ROOT}/public/service/product/#{@purchase.product_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/product/#{@purchase.product_id}.js")
#          File.delete("#{RAILS_ROOT}/public/service/category/#{@purchase.product.category_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/category/#{@purchase.product.category_id}.js")
#        end
#    end


#   session[:purchase_id] = @purchase.id
    
#  end
  
  def send_sms_to_consumer
    
    if Current.policy.online? and Current.policy.send_sms?
      sms_phone = @consumer.billing_phone
      sms_message = "Thank you for using arca! your PIN code is: #{session[:expected_pin]}"
      sms(sms_phone,sms_message)
    end
      
  end        
  
  def sms(phone, message)

    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    begin
      api.send_message(phone, message)
    rescue # doesn't work
      @sms_failed = true
    end
    
  end
  
  
  def account_for(amount)
# move to model, initialize etc

    @retailer = session[:retailer] 
    collected = @retailer.collected || 0 
    collected += amount
    
#    @retailer.update_attribute(:collected, collected)              # this doesnt work nor simple save!
#### WACKO CODE
    retailer_clone = @retailer.clone
    retailer_clone.id = @retailer.id
    retailer_clone.collected = collected
    retailer_clone.updated_at = Time.now
    @retailer.delete
    retailer_clone.save
#### WACKO CODE
    
    @consumer = session[:consumer]
    begin
      @consumer.balance -= amount
    rescue NoMethodError                      #old test data didnt set initial balance to 0
      @consumer.balance = 0
      retry
    end
    @consumer.save

  end
  
  def get_status
   
  end

  private

  def ensure_friend_authenticated    
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  
#  def ensure_consumer_authenticated

#    if session[:consumer] and session[:payer]
#    #TODO: return only if he is also logged in - current_facebook_user is on (maybe because of offline access)  
#       return
#    end

#    if current_facebook_user
#       session[:current_facebook_user_id] = current_facebook_user.id
#       consumer = Consumer.find_by_facebook_id(session[:current_facebook_user_id]) 
#       redirect_to   :action => :register unless consumer and consumer.facebook_id and consumer.payer.registered?
#    else
#       redirect_to   :action => 'login'
#    end
          
#  end
  


 
 end
