class Safecharge
  include HTTParty
  base_uri 'https://secure.safecharge.com'
end

class ServiceController < ApplicationController

   before_filter   :check_friend_authenticated    

  
  def index  
    
  end

  def registration   

  end
    
  def safecharge_page
    
    merchant_site_id = "34721"
    merchant_id = "4678792034088503828"
    time_stamp = "2010-08-25%2011:12:52"
    total_amount = "1"
    currency = "USD"
    checksum = "f83c5b1a24e6fbe64dc14a1ff5fe4d8c"
    item_name_1 = "test"
    item_amount_1 = "1"
    item_quantity_1 = "1"
    version = "3.0.0"
    success_url = "http://alpha.paykido.com/service/sc_success"
    error_url = "http://alpha.paykido.com/service/sc_success" 
    
    Safecharge.post('/ppp/purchase.do', :query => {
     :merchant_site_id => merchant_site_id,
     :merchant_id => merchant_id, 
     :time_stamp => time_stamp,
     :total_amount => total_amount,
     :currency => currency, 
     :checksum => checksum, 
     :item_name_1 => item_name_1, 
     :item_amount_1 => item_amount_1, 
     :item_quantity_1 => item_quantity_1, 
     :version => version})
     
    redirect_url = "https://secure.safecharge.com/ppp/purchase.do?" +
      "&merchant_site_id=" + merchant_site_id +
      "&merchant_id=" + merchant_id +
      "&time_stamp=" +  time_stamp +  
      "&total_amount=" + total_amount +
      "&currency=" + currency + 
      "&checksum=" + checksum +
      "&item_name_1=" + item_name_1 +
      "&item_amount_1=" + item_amount_1 +
      "&item_quantity_1=" + item_quantity_1 +
      "&version=" + version +
      "&success_url=" + success_url +
      "&error_url=" + error_url +
      "&pending_url=" + error_url
                   
                   
    redirect_to redirect_url
    
  end
  
  def keep_sc_success
    # indicate 'registered' on the payer record and record the sc token on a new payer field
    # redirect him to his prepared account if there is, with a message that he's succesfully registered
    # call the kid to inform registration has been completed
    
    @status = params[:Status]
    @amount = params[:totalAmount]
    @code = params[:ErrCode]
    @reason = params[:Reason]
    @token = params[:Token]
  end
  
  def keep_sc_error
    @status = params[:Status]
    @amount = params[:totalAmount]
    @code = params[:ErrCode]
    @reason = params[:Reason]
    @token = params[:Token]   
  end
  
  def sc_error
    flash[:message] = "Congratulations! You are registered to Paykido!"
    redirect_to  :controller => "subscriber", :action => payer_signedin
  end
 
  
  def check_friend_authenticated 
    session[:req_controller] = params[:controller]
    session[:req_action] = params[:action]
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  

end
