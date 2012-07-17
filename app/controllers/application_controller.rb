class ApplicationController < ActionController::Base

  before_filter :check_and_restore_session  
#  before_filter :set_locale
  include Facebooker2::Rails::Controller

  layout :set_layout

  private

#  def set_locale
#    I18n.locale ||= params[:locale] 
#  end

#  def default_url_options
#    {:locale => I18n.locale}
#  end

  def check_and_restore_session 
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id

    flash[:error] = nil
    if params[:payer_id]
      begin    
        @payer = Payer.find(params[:payer_id])
        @name = @payer.name 
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such payer. Please log in."
        return
      else
        if @payer.id != session[:payer_id]
            flash[:error] = "Please log in first"
            return
        end
      end
    end
      
    if params[:email] and params[:token]
      begin    
        @payer = Payer.authenticate_by_token(params[:email], params[:token])
        @name = @payer.name 
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such token"
        return
      end      
    end

    if params[:consumer_id]
      begin    
        @consumer = Consumer.find(params[:consumer_id])
        @name = @consumer.name
        @payer = @consumer.payer
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such consumer"
        return
      end  
    end

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
