class ApplicationController < ActionController::Base

  before_filter :set_name
# before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  def after_sign_in_path_for(payer)
    if current_payer.registered?
      return purchases_path
    else
      return new_token_path
    end
  end

  private

#  def set_locale
#    I18n.locale ||= params[:locale] 
#  end

#  def default_url_options
#    {:locale => I18n.locale}
#  end
  
  def set_name
    @name = (params[:consumer_id]) ? Consumer.find(params[:consumer_id]).name : current_payer.name if current_payer
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
