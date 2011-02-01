class AaaController < ApplicationController
  
  def main
    if session[:consumer_id]
      @consumer = Consumer.find(session[:consumer_id])
      @purchase = Purchase.find(session[:purchase_id])
    end   
  end
  
  def clear_session
    session[:consumer_id]=session[:payer_id]=session[:retailer_id]=session[:product_id]=session[:expected_pin]=nil
    session[:purchase_authorized]=session[:purchase_authorization_type]=nil
  end

  def authorize

# if consumer has populated his number in that session already, just  "go ahead and enter pin" 
# authorize purchase, sending sms to payer if required
# message: "Hello again! type in your PIN" || "SMS sent to you with PIN" || "Payer needs to authorize" || #(denial rsn)

    if session[:consumer_id] and session[:purchase_authorized]
      @message = "Hi again. Go ahead and enter the PIN code"
    elsif session[:consumer_id] and !session[:purchase_authorized]
      @status = session[:purchase_authorization_type]
      @message = "You may want to take care of that!"
      clear_session
    else
      get_retailer_and_product
      find_consumer_and_payer
      find_retailer_and_product
      create_purchase
      authorize_purchase
      set_authentication_method if @purchase_authorized
    end
    
  end

  def authenticate
    
# checks that keyed pin matches the session[:expected_pin] (previously set by authenticate)

    @purchase = Purchase.find(session[:purchase_id])
    if @purchase.authorization_date? and params[:pin]== session[:expected_pin]
      @message = "You've got it! Back to game..."
      account(@purchase.amount)
      clear_session
    elsif !@purchase.authorization_date
      @message = "Please hold until purchase is approved"
    else
      @message = "Wrong PIN entered. Please try again"
    end 

  end
  

  def find_consumer_and_payer

     @consumer = Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
     unless @consumer
        @consumer = Consumer.new(params[:consumer])
        @consumer.payer = Payer.new
        @consumer.save!
     end
     @payer = @consumer.payer
     session[:consumer_id] = @consumer.id
     session[:payer_id] = @payer.id
     
  end
  
  
  def get_retailer_and_product
    @retailer_name = "hula"
    @product_title = "zmat"
    @product_price = 9.99
    
  end

  def find_retailer_and_product
    @retailer = Retailer.find_or_create_by_name(@retailer_name)
    @product = @retailer.products.find(:first, 
              :conditions => ["title = ? and price = ?", @product_title, @product_price])                                   
    unless @product
      @product = @retailer.products.create(:category_id => 1, :title => @product_title, :price => @product_price)
    end
    session[:retailer_id] = @retailer.id
    session[:product_id] = @product.id
  end
    

  def create_purchase
     @purchase = @payer.purchases.create(:payer_id => @payer.id, :retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now)
     session[:purchase_id] = @purchase.id
  end
  
  def authorize_purchase

    if @payer.user?
      @rule = @payer.most_recent_payer_rule
      
      if @payer.balance <= 0
        @purchase.authorization_type = "ZeroBalance"
        @purchase_authorized = nil      
      elsif @payer.balance < @purchase.amount
        @purchase.authorization_type = "InsufficientBalance"
        @purchase_authorized = nil
        
      elsif @purchase.amount <= @rule.auto_authorize_under
        @purchase.authorization_type = "AutoUnder"
        @purchase_authorized = true
      elsif @purchase.amount > @rule.auto_deny_over
        @purchase.authorization_type = "AutoOver"
        @purchase_authorized = nil
      else
        @purchase.authorization_type = "PendingPayer"
        manually_authorize(@rule.authorization_phone, @retailer.name, @product.title, @product.price)
        @purchase_authorized = nil
      end

    else
      @purchase.authorization_type = "NoPayer"
      @purchase_authorized = true
    end
    
    if @purchase_authorized
      @purchase.authorization_date = Time.now    
    end
    
    @purchase.save
    @status = @purchase.authorization_type
    session[:purchase_authorized] = @purchase_authorized
    session[:purchase_authorization_type] = @purchase.authorization_type
  end
  
  def manually_authorize(phone, retailer, product, price)
    authorization_method = "sms"
    message = "need your approval for #{retailer} #{product} #{price}"
    sms(phone, message)if authorization_method == "sms"
  end
  
  def set_authentication_method
    
    if @payer.user?
      session[:expected_pin] = @payer.pin
      @message = "Welcome back! Just key in your PIN code"
      @status = "Expected PIN: #{session[:expected_pin]}"
    else
      pin = rand.to_s.first(4)
      session[:expected_pin] = pin
      sms_phone = @consumer.billing_phone
      sms_message = "your PIN code is: #{pin}"
      sms(sms_phone,sms_message)
      @message = "an SMS was sent to you with PIN code"
      @status = "Generated PIN: #{pin}"      
    end
    
  end
  
  def sms(phone, message)

  end
  
  
  def save_session
#    session[:consumer] = @consumer
#    session[:payer] = @payer
#    session[:rule] = @payer.most_recent_rule
#    session[:retailer]= @retailer
#    session[:product] = @product
  end
  
#
# 2nd call - accepting pin from the user
# need to _get things from the session
#
  
 
  def account(amount)
    @payer = Payer.find(session[:payer_id])
    @retailer = Retailer.find(session[:retailer_id])
    @payer.balance -= amount
    @retailer.collected += amount
    @payer.save
    @retailer.save
    end
  
  def get_status
   
  end
 
 end
