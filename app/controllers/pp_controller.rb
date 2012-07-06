class PpController < ApplicationController::Base



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
  
end