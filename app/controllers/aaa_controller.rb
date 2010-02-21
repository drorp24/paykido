require 'ruby-debug'
class AaaController < ApplicationController

  def authenticate
    
  end

  def process_request
    get_retailer_and_product
    find_retailer_and_product
    find_payer
    create_purchase
    authorize
    authenticate
  end
  
  def get_retailer_and_product
    @retailer_name = "hula"
    @product_title = "zmat"
    @product_price = 199
  end

  def find_retailer_and_product
    @retailer = Retailer.find_or_create_by_name(@retailer_name)
    @product = @retailer.products.find(:first, 
              :conditions => ["title = ? and price = ?", @product_title, @product_price])                                   
    unless @product
      @retailer.products.create(:category_id => 1, :title => @product_title, :price => @product_price)
    end
  end
    
  def find_payer
     unless Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
      @consumer = Consumer.new(params[:consumer])
      @consumer.payer = Payer.new
      @consumer.save!
    end    
  end
  
  def create_purchase
    
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
