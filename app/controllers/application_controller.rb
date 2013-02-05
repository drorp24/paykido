class ApplicationController < ActionController::Base

  before_filter :find_scope
# before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  def after_sign_in_path_for(payer)

      Rails.logger.debug("entered after_sign_in_path")  
      Rails.logger.debug("current_payer.id: " + current_payer.id.to_s)  

    if current_payer.purchases.any?
      Rails.logger.debug("there are purchases")  
      return purchases_path
    elsif current_payer.registered?
      Rails.logger.debug("current payer is registered")  
      return tokens_path
    else
      Rails.logger.debug("current payer is not registered")  
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
  
  def find_scope
    
    # Find if scope is one consumer (@consumer) or entire payer 
 
    if params[:consumer_id] and @consumer = Consumer.find_by_id(params[:consumer_id])
      @name = @consumer.name
#    elsif current_payer and current_payer.name
#      @name = current_payer.name
    elsif current_payer and current_payer.consumers.count > 1
      @name = "the entire family"
    else
      @name = "All"
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
