
class ControlController < ApplicationController

  def index
    
    @purchases = Purchase.where("payer_id = 63").includes(:consumer, :retailer, :product, :category)
    @pendings = Purchase.where("payer_id = ? and authorization_type = ?", 63, 'PendingPayer').count
    @payer = Payer.find(63)
    @consumer = Consumer.find(281)
    @name = @consumer.name
    session[:consumer] = @consumer

    render :layout => false
    
  end
  
  def consumer # temp - delete!
    @consumer = Consumer.find(281)
    @name = @consumer.name
    
    render :layout => false
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

  
  def consumer_update
    
    find_consumer
    
    if params[:consumer] 

      allowance_changed = true if params[:consumer][:allowance] and params[:consumer][:allowance] != @consumer.allowance
      period_changed = true if params[:consumer][:allowance_period] and params[:consumer][:allowance_period] != @consumer.allowance_period    
          
      @consumer.record_allowance_change if allowance_changed or period_changed
      if @consumer.update_attributes(params[:consumer])
          @consumer.update_defaults if period_changed
          @consumer.save!
          session[:consumer] = @consumer
      else
          @error = @consumer.errors[:base][0]
          @consumer = session[:consumer]= Consumer.find(@consumer.id)
      end

    end
        
    respond_to do |format|  
      format.js
      format.html {redirect_to zzz}
       
    end
    
  end
  
    def approval
    
    @purchase = session[:purchase] = Purchase.find(params[:id])
    @consumer = @purchase.consumer
    @payer = @purchase.payer
    @approved = (params[:approved] == 'true')
    @activity = session[:activity] = (@approved) ?'approve' :'decline'
    @title = @purchase.product.title
    @category = @purchase.category.name
    @merchant = @purchase.retailer.name

    if @payer.registered?
      
      @merchant_whitelisted = @purchase.retailer.whitelisted?(@payer.id, @consumer.id)
      @merchant_blacklisted = @purchase.retailer.blacklisted?(@payer.id, @consumer.id)
      @category_whitelisted = @purchase.category.whitelisted?(@payer.id, @consumer.id)
      @category_blacklisted = @purchase.category.blacklisted?(@payer.id, @consumer.id)
    end
    
  end

  def purchase
    
    @purchase = Purchase.find(params[:id])
    @retailer_name = @purchase.retailer.name
    @retailer_logo = @purchase.retailer.logo
    @product_title = @purchase.product.title
    @amount = @purchase.amount
    @category = @purchase.category.name

    render :layout => false
    
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