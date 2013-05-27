class ParametersController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_purchase  

  def index
    @params = @purchase.params
  end

  private

  def find_purchase  
 
    if params[:purchase_id]
      begin    
        @purchase = Purchase.find(params[:purchase_id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
