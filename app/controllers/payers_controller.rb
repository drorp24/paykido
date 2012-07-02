class PayersController < ApplicationController

  before_filter :check_and_restore_session    
# before_filter :set_long_expiry_headers    # consider moving to application controller

 
  def set
    
  end

  private 

  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    if params[:id]
      @payer = Payer.find(params[:id])
    elsif params[:email] and params[:token]
      @payer = Payer.authenticate_by_token(params[:email], params[:token])
    end
     
  end
  

 
end
