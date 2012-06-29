class ApplicationController < ActionController::Base

  before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  def set_locale
    I18n.locale = params[:locale] 
  end

  private
  
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
