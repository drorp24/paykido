
class DashboardController < ApplicationController

  def index
    
  end
  
  def login
    
    if request.post?
           
      unless session[:user] = User.authenticate(params[:user][:email], params[:user][:password])
        flash.now[:notice] = "user or password are incorrect. Please try again!"
        return
      end
      
#     set_payer_session
      redirect_to :action => :index
    end
          
  end

  def dashboard
    @purchases = Purchase.where("payer_id = 63").includes(:consumer, :retailer, :product, :category)
    @pendings = Purchase.where("payer_id = ? and authorization_type = ?", 63, 'PendingPayer').count
    @payer = Payer.find(63)
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