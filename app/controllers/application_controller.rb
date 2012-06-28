class ApplicationController < ActionController::Base
  before_filter :set_locale
  include Facebooker2::Rails::Controller

  def set_locale
    I18n.locale = params[:locale] 
  end

  private
  
  def check_and_restore_session  
 
    # replace with Devise  
    unless @payer = session[:payer] or @payer = Payer.authenticate_by_token(params[:email], params[:token]) 
      flash[:message] = "Please sign in with payer credentials"
      reset_session
      redirect_to  :controller => 'home', :action => 'index'
      return
    end

  end
  
  def set_long_expiry_headers
    response.headers["Expires"] = CGI.rfc1123_date(Time.now + 1.year)   
  end
               
  
  #protect_from_forgery
end
