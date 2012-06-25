class Safecharge
  include HTTParty
  base_uri 'https://secure.safecharge.com'
end

# Most of this controller handles the API between Paykido and the Payment Service Providers (PSP) it intergates with
# It should be dealt with only upon integration (July 2012)
# Currently it contains two PSPs: SafeCharge (SC) and PayPal
# The code should be moved to controllers per each PSP

class G2sController < ActionController::Base

  def ppp_callback    ## /ppp/<status>
    # return to originating page and produce the proper message
    # (data itself is taken from dmn, though some of it is in the returned params)
    
  end
  
  def dmn
    # return status to G2S if anything is wrong (e.g., hash not ok etc)
    
  end


####  
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

  def sms(phone, message)
    
    begin
      api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
      api.send_message(phone, message)
    rescue 
      return false
    else
      return "sent"
    end
    
  end

  def pay_retailer     # choose which gw to use
    
    retailer_paid = true if safecharge_gw == "APPROVED"
     
  end

  def paypal_gw
    
    pay_request = PaypalAdaptive::Request.new
    
    data = {
    "returnUrl" => "",
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=>"USD",
    "cancelUrl"=>"",
    "senderEmail" => "drorp1_1297098617_per@yahoo.com",
    "receiverList"=>{"receiver"=>
        [{"email"=>"drorp2_1297098512_biz@yahoo.com", "amount"=>""}]},
    "actionType"=>"PAY",
    "trackingId" => "",
    "preapprovalKey" => session[:preapprovalKey],
    "ipnNotificationUrl"=>""    }
    
    pay_response = pay_request.pay(data)
    
    if pay_response.success?
      flash[:message] = "Thank you!"
      @retailer_paid = true
      redirect_to ""
    else
      puts pay_response.errors.first['message']
      flash[:message] = pay_response.errors.first['message']
      retailer_paid = false
      redirect_to ""
    end    
    
  end 
  
  def safecharge_gw
        
    sg_NameOnCard = "John Smith"
    sg_CardNumber = "1234567812345678"
    sg_ExpMonth = "12"
    sg_ExpYear = "24"
    sg_CVV2 = "123"
    sg_TransType = "Sale"
    sg_Currency = "USD"
    sg_Amount = @product.price.to_s
    sg_ClientLoginID = "Paykido_TRX"
    sg_ClientPassword = "password"
    sg_ResponseFormat = "4"
    sg_FirstName = @payer.name
    sg_LastName = @payer.family || "Smith"
    sg_Address = "1000 Pine Grove"
    sg_City = "Milpitas"
    sg_Zip = "92535"
    sg_Country = "US"
    sg_Phone = "2131234567"
    sg_IPAddress = request.remote_ip
    sg_Email = @payer.email || "johnsmith@yahoo.com"
    
    gw = Safecharge.get('/service.asmx/Process', :query => {
     :sg_NameOnCard => sg_NameOnCard,
     :sg_CardNumber => sg_CardNumber, 
     :sg_ExpMonth => sg_ExpMonth,
     :sg_ExpYear => sg_ExpYear,
     :sg_CVV2 => sg_CVV2, 
     :sg_TransType => sg_TransType, 
     :sg_Currency => sg_Currency, 
     :sg_Amount => sg_Amount, 
     :sg_ClientLoginID => sg_ClientLoginID, 
     :sg_ClientPassword => sg_ClientPassword,
     :sg_ResponseFormat => sg_ResponseFormat,
     :sg_FirstName => sg_FirstName,
     :sg_LastName => sg_LastName,
     :sg_Address => sg_Address,
     :sg_City => sg_City,
     :sg_Zip => sg_Zip,
     :sg_Country => sg_Country,
     :sg_Phone => sg_Phone,
     :sg_IPAddress => sg_IPAddress,
     :sg_Email => sg_Email     
     })
     
     @gw_reason = gw[:Response][:Reason]
     @gw_status = gw[:Response][:Status]
    
  end


  #protect_from_forgery
end
