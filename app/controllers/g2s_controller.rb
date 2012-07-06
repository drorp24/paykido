class Safecharge
  include HTTParty
  base_uri 'https://secure.safecharge.com'
end


# Most of this controller handles the API between Paykido and the Payment Service Providers (PSP) it intergates with
# It should be dealt with only upon integration (July 2012)
# Currently it contains two PSPs: SafeCharge (SC) and PayPal
# The code should be moved to controllers per each PSP

class G2sController < ApplicationController

  def ppp_callback    ## /ppp/<status>
    # return back to originating page: whether settings or purchases (dashboard)
    # (data itself is taken from dmn, though some of it is in the returned params)

    # redirect (or render?) this or the other
    # store in advance and use here the purchase id and dont count on session!
    
    if params[:customField1] == 'payment'
      default_url_options[:host] = "localhost:3000"
        redirect_to purchase_url(params[:customField2].to_i, params.except(:action, :controller))
    else
      flash[:error] = ""
      redirect_to root_path
    end
        
  end
  
  def dmn
    # read dmn and store the properties in either a. registration or b. transaction
    # do not count on session to include anything to 'remind' of the context
    # instead, use the custom field to 'remind' the server what the context is
    
    # if this is a (succesful) transaction, notify/approve/inform (make it DRY by having them all in the model)
    # dont render anything or redirect anywhere
    logger.info "DMN was called!"

    redirect_to dmn_url(params.except(:action, :controller)) if Rails.env.development?
    if params[:customField1] == 'payment'
      @purchase.create_transaction!(params)
      # notify/approve/inform      
    elsif params[:customField1] == 'approval'
      @payer.registrations.create_new!
    else
      return false   
    end
    
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

  def pay_retailer     # choose which gw to use
    
    retailer_paid = true if safecharge_gw == "APPROVED"
     
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
