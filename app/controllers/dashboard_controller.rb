
class DashboardController < ApplicationController

  def index
    
  end
  
  def login
    
  end

  def dashboard
    @purchases = Purchase.where("payer_id = 63").includes(:consumer, :retailer, :product, :category)
    @consumer = Consumer.find(281)
    session[:consumer] = @consumer
  end
  
  def consumer_update
    
    find_consumer

    if params[:consumer] 
      if  params[:consumer][:allowance] or params[:consumer][:allowance_period]
            @consumer.record_allowance_change
      end
      if @consumer.update_attributes!(params[:consumer])
          session[:consumer] = @consumer
      else
          flash[:notice] = "Invalid... please try again!"
          return
      end
    end
        
    respond_to do |format|  
      format.js  
    end
    
  end

  private

  def find_consumer
    
    if session[:consumer] and session[:consumer].id == params[:id]
      @consumer = session[:consumer]
     else
      @consumer = Consumer.find(params[:id])
    end
   
    session[:consumer] = @consumer

  end

end