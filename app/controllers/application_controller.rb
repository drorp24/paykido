class ApplicationController < ActionController::Base

  before_filter :find_scope
# before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  def after_sign_in_path_for(payer, notify=nil)

    Rails.logger.debug("entered after_sign_in_path")  

    if current_payer.consumers.any?
      consumer = current_payer.consumers.first
      return consumer_statistics_path(consumer, :notify => notify)
    elsif current_payer.registered?
      return tokens_path(:notify => notify)
    else
      return new_token_path(:notify => notify)
    end
  end
  
  def after_sending_reset_password_instructions_path_for(payer)

    Rails.logger.debug("entered after_sending_reset_password_instructions_path")  

  return root_path(:anchor => "teens", :notify => 'confirmation')
    
  end
  
  def signed_in_root_path(payer, notify=nil)
    Rails.logger.debug("entered signed_in_root_path")  

    if current_payer.consumers.any?
      consumer = current_payer.consumers.first
      return consumer_statistics_path(consumer, :notify => notify)
    elsif current_payer.registered?
      return tokens_path(:notify => notify)
    else
      return new_token_path(:notify => notify)
    end
    
  end

    

  private

#  def set_locale
#    I18n.locale ||= params[:locale] 
#  end

#  def default_url_options
#    {:locale => I18n.locale}
#  end
  
  def find_scope
    
    if params[:consumer_id]
      @consumer = Consumer.find_by_id(params[:consumer_id])
    elsif params[:controller] == "consumers" and params[:id]
      @consumer = Consumer.find_by_id(params[:id])
    end

  end

  def set_long_expiry_headers
    response.headers["Expires"] = CGI.rfc1123_date(Time.now + 1.year)   
  end
               
  def set_layout

    if request.headers['X-PJAX'] or request.xhr?
      false
    elsif devise_controller?
      "home"
    else
      "application"
    end
  end
  
  #protect_from_forgery
end
