class ApplicationController < ActionController::Base
  before_filter :set_locale
   include Facebooker2::Rails::Controller

  def set_locale
    I18n.locale = params[:locale] 
  end
  
  #protect_from_forgery
end
