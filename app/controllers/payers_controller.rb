class PayersController < ApplicationController

  before_filter :check_and_restore_session  
 

  private
  
  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    super
    
    if params[:id]
      begin    
        @payer = Payer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such payer id"
        redirect_to root_path
        return
      end 
    end           

  end
  
end
