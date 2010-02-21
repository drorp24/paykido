require 'ruby-debug'
class AaaController < ApplicationController

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
    @product_price = 300.00
    
  end

  def find_retailer_and_product
    @retailer = Retailer.find_or_create_by_name(@retailer_name)
    @product = @retailer.products.find(:first, 
              :conditions => ["title = ? and price = ?", @product_title, @product_price])                                   
    unless @product
      @retailer.products.create(:category_id => 1, :title => @product_title, :price => @product_price)
      @product = @retailer.product
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
    debugger
     @payer.purchases.create(:retailer_id => @retailer.id, :product_id => @product.id, :amount => @product.price, :date => Time.now)
  end
  
  def authorize
#    if consumer.payer.username?
      
#    end
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
