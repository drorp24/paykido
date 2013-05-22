class NotificationsController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_notification  

  def index
    @notifications = @purchase.notifications
  end

  def show

  end


  private

  def find_notification  
 
    if params[:purchase_id]
      begin    
        @purchase = Purchase.find(params[:purchase_id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

    if params[:id]
      begin    
        @notification = @purchase.notifications.find(params[:id])  
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such notification id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
