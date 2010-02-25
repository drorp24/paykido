require 'ruby-debug'
class AaaController < ApplicationController
  
  def main
 
  end
  
  def get_retailer_and_product
    @retailer_name = "hula"
    @product_title = "zmat"
    @product_price = 9.99
    
  end
  
  def set_session
    
    get_retailer_and_product
    
    unless  session[:billing_phone] == params[:consumer][:billing_phone]and
            session[:retailer_name] == @retailer_name and
            session[:product_title] == @product_title and
            session[:product_price] == @product_price
            
       clear_session
    end
        
  end
  
  def clear_session
# find a better command to clear out all session construct
    session[:consumer_id]=session[:payer_id]=session[:retailer_id]=session[:product_id]=session[:purchase_id]=nil
    session[:expected_pin]=nil
    session[:billing_phone]=session[:retailer_name]=session[:product_title]=session[:product_price]=nil
  end
  

  def no_use_waiting
    
    if session[:purchase_id]

        @purchase = Purchase.find(session[:purchase_id]) 
        
        if @purchase.authorization_type == "PendingPayer"
          @status = "Please hold while this purchase is getting approved"
          @message = "Or try anothr one in the mean time"
          true
        elsif !@purchase.authorization_date
          @status = "I'm afraid this purchase is unauthorized"
          @message = "How about trying any of the other items?"
          true
        else
          nil
        end
      
    else
      nil
    end 
    
  end
  
  def authorize
    
  set_session

  unless no_use_waiting

    if session[:purchase_id] and @purchase.authorization_date?
      @status = "Welcome back"
      @message = "Go ahead and enter the PIN code now"
# manual authorization updates: 1. purchase record (2 fields) 2. sends the sms to the consumer
# if he's here then we can assume that an SMS has been sent and accepted by the consumer
    else
      find_consumer_and_payer
      find_retailer_and_product
      find_or_create_purchase
      authorize_purchase
      set_expected_pin
      send_sms_to_consumer if @purchase.authorization_date?
      write_message
    end
    
  end

end

  def write_message
    
    if @purchase.authorization_type = "PendingPayer" 
      @status = "This purchase has to be manually authorized"
      @message = "We will send you an SMS as soon as it is approved"
    elsif !@purchase.authorization_date
      @status = "We're sorry. This purchase was unauthorized (#{@purchase.authorization_type})"
      @message = "Would you like to try buying any other item?"
    elsif @payer.user?
      @status = "Welcome back!"
      @message = "Go ahead and key in your permanent PIN"
    else
      @status = "Thank you"
      @message = "an SMS with the PIN code is on its way!"
    end  
 
  end

  def authenticate
    

  unless no_use_waiting
      
    @purchase = Purchase.find(session[:purchase_id])
    
    if @purchase.authorization_date? and params[:pin]== session[:expected_pin]
      @status = "That's it. You're done."
      @message = "Enjoy the game!"
      account(@purchase.amount)
      clear_session
    else
      @status = "Wrong PIN entered (#{session[:expected_pin]})"
      @message = "Please try again"
    end

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
       @purchase = @payer.purchases.create(:payer_id => @payer.id, :retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now)
       session[:purchase_id] = @purchase.id       
     end
   
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
        
      elsif @purchase.authorization_type == "ManuallyAuthorized"
        @purchase_authorized = true
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
    session[:purchase_id] = @purchase.id

  end
  
  def manually_authorize(phone, retailer, product, price)
    authorization_method = "sms"
    sms_message = "need your approval for #{retailer} #{product} #{price}"
    sms(phone, sms_message)if authorization_method == "sms"
  end
  
  def set_expected_pin
    
    if @payer.user?
      session[:expected_pin] = @payer.pin
    else
      session[:expected_pin] = rand.to_s.first(4)
    end 
 
  end
  
  def send_sms_to_consumer
    
      sms_phone = @consumer.billing_phone
      sms_message = "your PIN code is: #{pin}"
      sms(sms_phone,sms_message)
      
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
