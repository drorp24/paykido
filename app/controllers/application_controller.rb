class ApplicationController < ActionController::Base

  before_filter :check_and_restore_session  
  before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  def set_locale
    I18n.locale = params[:locale] 
  end

  private
  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    if params[:payer_id]
      @payer = Payer.find(params[:payer_id])
    elsif params[:email] and params[:token]
      @payer = Payer.authenticate_by_token(params[:email], params[:token])
    end
    if params[:consumer_id]
      @consumer = Consumer.find(params[:consumer_id])
    end
    if params[:id]
      @purchase = Purchase.find(params[:id])
    end
    if params[:customField2]
      @purchase = Purchase.find(params[:customField2])
    end
    
    @consumer ||= @purchase.consumer if @purchase
    @payer ||=    @purchase.payer if @purchase
     
  end

  def set_long_expiry_headers
    response.headers["Expires"] = CGI.rfc1123_date(Time.now + 1.year)   
  end
               
  def set_layout
    if request.headers['X-PJAX']
      false
    else
      "application"
    end
  end
  
  #protect_from_forgery
end
