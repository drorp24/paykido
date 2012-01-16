class Safecharge
  include HTTParty
  base_uri 'https://secure.safecharge.com'
end


class ApplicationController < ActionController::Base
  before_filter :set_locale
  include Facebooker2::Rails::Controller

  def set_locale
    I18n.locale = params[:locale] 
  end
  
  def pay(merchant_site_id, merchant_id, item, amount, currency, success_url, error_url)

    safecharge_page(merchant_site_id, merchant_id,item, amount, currency, success_url, error_url)

  end

  def submit_payment_details(succes_url, error_url)
    
    # check with SC what params to give it for registration
    safecharge_page("???", "???", "test?", "1?", "USD??", success_url, error_url)  

  end
    
  def test_payment_details(success_url, error_url)
    
    # check with SC what params to give it for registration
    safecharge_page("34721", "4678792034088503828", "test", "1", "USD", success_url, error_url)  

  end

  def safecharge_page(p_merchant_site_id, p_merchant_id, p_item_name, p_amount, p_currency, p_success_url, p_error_url)
         
    merchant_site_id = p_merchant_site_id   
    merchant_id = p_merchant_id 
    time_stamp = "2010-08-25%2011:12:52"             # temp for tests
    total_amount = p_amount.to_s 
    currency = p_currency 
    checksum = "f83c5b1a24e6fbe64dc14a1ff5fe4d8c"    # calculate it based on the other parameters
    item_name_1 = p_item_name 
    item_amount_1 = p_amount.to_s 
    item_quantity_1 = "1"
    version = "3.0.0"
    success_url = p_success_url
    error_url = p_error_url 
    
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
     :version => version
     })
     
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
      "&error_url=" + error_url 
                                      
    redirect_to redirect_url
    
  end

  
  #protect_from_forgery
end
