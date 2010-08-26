require 'ruby-debug'
require 'rubygems'
require 'clickatell'

class AaaController < ApplicationController
  
  def main
    
    @products = Product.find_product_options(1)
 
  end

  def select_product

    session[:product] = Product.find(params[:id])
    session[:product_title] = session[:product].title
    session[:product_price] = session[:product].price
    session[:retailer_name] = "Zynga"
    @status = "You have selected " + session[:product].title
    
  end
  
  def set_session  

  # If no product was selected first, no use to do anything. This will be found in no_use_waiting, which is next.  
    if session[:product].nil?
      @no_product_selected = true
      return
    end

  # We can therefore assume that the following must be set by now
    @product = session[:product]
    @product_title = session[:product_title]
    @product_price = session[:product_price]
    @retailer_name = "Zynga"
    
  # We clear the product session, to force passing thru the product selection next time too
  # For the rest of that call, we should use only @ product variables, not session ones
    session[:product] = session[:product_title] = session[:product_price] = nil
    

  # if the phone in the parameters matches the prev one, and the product matches the prev purchase, then we assume it's the same session:
  # that means we're expecting the same pin, or still waiting, or no use waiting, or just about to complete the process now. 
  # However, if it differs, we clear the session

    if params[:consumer][:billing_phone] == session[:billing_phone] and
       session[:purchase_id] and
       @product.id == Purchase.find(session[:purchase_id]).product_id  
 
       @consumer = session[:consumer]
       @billing_phone = session[:billing_phone]
       @purchase = Purchase.find(session[:purchase_id]) 

    else

       clear_session
       @consumer = Consumer.find_or_initialize_by_billing_phone(params[:consumer][:billing_phone])
       session[:consumer] = @consumer
       @billing_phone = params[:consumer][:billing_phone]
       session[:billing_phone] = @billing_phone

    end
     
   end
         
  
   def clear_session
  # find a better command to clear out all session construct
      session[:consumer]=session[:billing_phone]=
      session[:payer_id]=
      session[:retailer_id]=session[:retailer_name]=
      session[:product]=session[:product_title]=session[:product_price]=session[:product_id]=
      session[:purchase_id]=
      session[:expected_pin]=      
      nil
   end
    

  def no_use_waiting
    
    if @no_product_selected
      @status = "Please select product first"
      @message = "Then try again"
      true

    elsif @consumer.invalid? 
      @status = "Wrong phone number"
      @message = "Please try again"
      true
      
    elsif session[:purchase_id]
       
        if @purchase.authorization_type == "PendingPayer"
          @status = "Please hold while this purchase is being approved"
          @message = ""
          true
        elsif !@purchase.authorized
          @status = "We're sorry. This purchase was unauthorized"
          @message = ""
          true
        elsif @purchase.authorized
          @status = "Your purchase has been approved!"
          @message = "Go ahead and enter the PIN code now"
          true
        else
          false
        end
      
    else
      nil
    end 
    
  end
  
  def authorize
    
  set_session

  unless no_use_waiting
    begin

      find_consumer_and_payer
      find_retailer_and_product
      find_or_create_purchase
      authorize_purchase
      authenticate_consumer
      unless @sms_failed
        save_purchase
        write_message
      end
 
    rescue
      @status = "Service is temprarily down"
      @message = "Please hold on for a few moments"
      raise
     end
    
  end

end

  def authenticate_consumer
    
    if @payer.exists? and @payer.pin?
      
      @purchase.authentication_type = "PIN"
      session[:expected_pin] = @payer.pin
      
    elsif @purchase.authorized?
      
      @purchase.authentication_type = "SMS"
      session[:expected_pin] = rand.to_s.last(4)
      send_sms_to_consumer
    end 

  end

  def write_message
    
    if @purchase.authorization_type == "PendingPayer" 
      @status = "This purchase has to be manually authorized"
      @message = "You'll get an SMS as soon as it is approved"
    elsif !@purchase.authorized
      @status = "We're sorry. This purchase was unauthorized (#{@purchase.authorization_type})"
      @message = ""
    elsif @payer.exists? and @payer.pin?
      @status = "Welcome back!"
      @message = "Go ahead and key in your permanent PIN"
    elsif @payer.exists?
      @status = "Welcome back. An SMS is on its way."
      @message = "Make yourself a premanent PIN!"
    else
      @status = "Thank you"
      @message = "An SMS with the PIN code is on its way!"
    end  
 
  end

  def authenticate
    
    begin
      
    @purchase = Purchase.find(session[:purchase_id]) if session[:purchase_id]
    
    if @purchase
      expected_pin = @purchase.expected_pin || session[:expected_pin]
    
      if @purchase.authorized? and params[:pin]== expected_pin
        @status = "Your purchase is approved."
        @message = "Thanks for shopping with arca!"
        @purchase.authentication_date = Time.now
        @purchase.save
        account(@purchase.amount)
        clear_session
      elsif @purchase.authorized? and params[:pin] != expected_pin
        @status = "Wrong PIN entered (#{expected_pin})"
        @message = "Please try again"
      elsif !@purchase.authorized?
        @status = "We're sorry. This purchase is unauthorized"
        @message = ""     
        clear_session
      end
    else
        @status = "You need to get authorization first"
        @message = "Complete step 1 then try again"
    end

    rescue 
      @status = "Service is temprarily down"
      @message = "Please hold on for a few moments"
    end
  
  end

   
  def find_consumer_and_payer

     @consumer = Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
     unless @consumer
        begin
          @consumer = Consumer.new(params[:consumer])
          @consumer.payer = Payer.new(:exists => false)
          @consumer.save!
        rescue #RecordInvalid 
          flash[:notice] = "Consumer and/or payer didn't pass validation"
          raise
        end 
     end
     @payer = @consumer.payer
     @consumer_rule = @consumer.most_recent_payer_rule if @payer.exists
     session[:consumer] = @consumer
     session[:consumer_rule] = @consumer_rule 
     session[:billing_phone] = @consumer.billing_phone
     session[:payer_id] = @payer.id
     
  end
  
  
  def find_retailer_and_product
    @retailer = Retailer.find_or_create_by_name(@retailer_name)
    @product = @retailer.products.find(:first, 
              :conditions => ["title = ? and price = ?", @product_title, @product_price]) 
 
    unless @product
      @product = @retailer.products.create(:category_id => 1, :title => @product_title, :price => @product_price)
    end
    session[:retailer_id] = @retailer.id
    session[:retailer_name] = @retailer.name
    session[:product_id] = @product.id
    session[:product_title] = @product.title
    session[:product_price] = @product.price
  end
    

  def find_or_create_purchase
    
     if session[:purchase_id]
       @purchase = Purchase.find(session[:purchase_id])
     else
       @purchase = @payer.purchases.create(:consumer_id => @consumer.id, :payer_id => @payer.id, :retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now, :location => generate_location)
       session[:purchase_id] = @purchase.id       
     end
   
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
    
    
    @purchase.authorized = false                        
    
    if @payer.exists?
       @consumer = session[:consumer]
      @rule = session[:consumer_rule]
      if @purchase.product.is_blacklisted(@payer.id) or @purchase.retailer.is_blacklisted(@payer.id) or @purchase.product.category.is_blacklisted(@payer.id)
        @purchase.authorization_type = "Inappropriate Content"
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
        manually_authorize(@payer.phone, @retailer.name, @product.title, @product.price)
        @purchase.authorized = false
      end

    else
      @purchase.authorization_type = "NoPayer"
      @purchase.authorized = true
    end
        
      @purchase.authorization_date = Time.now
    
  end
  
  def save_purchase
    
    if @purchase.save
        File.delete("#{RAILS_ROOT}/public/service/purchases_all/Just show everything.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases_all/Just show everything.js")
        File.delete("#{RAILS_ROOT}/public/service/purchases/Pending.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/Pending.js")
    end

    session[:purchase_id] = @purchase.id
    
  end
  
  def manually_authorize(phone, retailer, product, price)
#    authorization_method = "sms"
#    sms_message = "need your approval for #{retailer} #{product} #{price}"
#    sms(phone, sms_message)if authorization_method == "sms"
  end
    
  
  def send_sms_to_consumer
    
      sms_phone = @consumer.billing_phone
      sms_message = "Thank you for using arca! your PIN code is: #{session[:expected_pin]}"
      sms(sms_phone,sms_message)
      
  end
        
  
  def sms(phone, message)

    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    begin
      api.send_message(phone, message)
    rescue Clickatell::API::Error
      @status = "Oops... can't locate that phone."
      @message = "Would you check the number and try again"
      @sms_failed = true
    end
    
  end
  
  
  def account(amount)
# move to model, initialize etc

    @retailer = Retailer.find(session[:retailer_id]) 
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
 
 end
