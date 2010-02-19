#require 'ruby-debug'
class AaaController < ApplicationController

  def authenticate
    
  end

  def process_request
    check_for_payer
    authorization
  end
  
  def check_for_payer
     unless Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
      @consumer = Consumer.new(params[:consumer])
      @consumer.payer = Payer.new
      @consumer.save!
    end    
  end
  
  def authorization
    
  end
  
  
  def subscriber_sms
    
  end
  def get_status
   
  end
 
  
  def check_status
    
  end

end
