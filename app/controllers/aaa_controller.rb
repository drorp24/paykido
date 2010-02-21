require 'ruby-debug'
class AaaController < ApplicationController

#
#move later to model classes
#

  def authenticate
    
  end

  def process_request
    get_retailer_and_product
    find_retailer_and_product
    find_consumer_and_payer
    create_purchase
    authorize
    authenticate
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
  end
    
  def find_consumer_and_payer
     @consumer = Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
     unless @consumer
        @consumer = Consumer.new(params[:consumer])
        @consumer.payer = Payer.new
        @consumer.save!
     end
     @payer = @consumer.payer
  end
  
  def create_purchase
     @purchase = @payer.purchases.create(:retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now)
  end
  
  def authorize
    if @consumer.payer.username?
      @rule = @payer.most_recent_payer_rule
      if @purchase.amount <= @rule.auto_authorize_under
        @purchase.authorization_type = "AutoUnder"
        @authorization = true
      elsif @purchase.amount > @rule.auto_deny_over
        @purchase.authorization_type = "AutoOver"
        @authorization = nil
      else
        @purchase.authorization_type = "AskingPayer"
        @authorization = manual_authorization(@rule.authorization_phone)
      end
    else
      @purchase.authorization_type = "NoPayer"
      @authorization = true
    end
#    debugger
    if @authorizatrion == true
      @purchase.authorization_date = Time.now    
    end 
    @authorization
  end
  
  def manual_authorization(phone)
    
  end
  
  def authenticate
    
  end
  
  
  def subscriber_sms
    
  end
  def get_status
   
  end
 
  
  def check_status
    
  end

end
