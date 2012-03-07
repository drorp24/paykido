class ControlController < ApplicationController

# 3 types of activities:
# => full page (e.g., control/dashboard)  triggered by sub-menu     return html   (default render)      ajax by Spina
# => pane replace (e.g., purchase)        trigered by link on page  return html   render layout false   ajax by me
# => update act(e.g., approve, whitelist) triggered by by button    return js     format js             ajax by me



  before_filter :check_and_restore_payer_session, :except => [:login, :logout]

  def login
    
    if request.post?
           
      unless session[:payer] = Payer.authenticate(params[:username], params[:password])
        flash.now[:notice] = "user or password are incorrect. Please try again!"
        redirect_to :controller => 'landing', :action => 'index'
        return
      end
      
      session[:consumer] = Consumer.find(281)         # temporary. No consumer is needed. Dashboard starts with family
      redirect_to :action => 'dashboard'
    end
          
  end
   
  def logout
    
  end 
  
  def dashboard

    # change to info
    @purchases = Purchase.where("payer_id = ?", @payer.id).includes(:consumer, :retailer)
    @pendings = @purchases.where("authorization_type = ?",'PendingPayer').count
    @name = @consumer.name

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
    @title = @purchase.product
    @category = @purchase.category.name
    @merchant = @purchase.retailer.name
  
    if @payer.registered?     
      @merchant_whitelisted = @purchase.retailer.whitelisted?(@payer.id, @consumer.id)
      @merchant_blacklisted = @purchase.retailer.blacklisted?(@payer.id, @consumer.id)
      @category_whitelisted = @purchase.category.whitelisted?(@payer.id, @consumer.id)
      @category_blacklisted = @purchase.category.blacklisted?(@payer.id, @consumer.id)
      @product_whitelisted = @purchase.product.whitelisted?(@payer.id, @consumer.id)
      @product_blacklisted = @purchase.product.blacklisted?(@payer.id, @consumer.id)
    end
    
  end

  def purchase
    
    @purchase = Purchase.find(params[:id])

    render :layout => false
    
  end
  
  def rule
    
    consumer = Consumer.find(params[:consumer])
    
    if params[:instruction] == 'approve'
      consumer.whitelist!(params[:property], params[:value])
    elsif params[:instruction] == 'decline' 
      consumer.blacklist!(params[:property], params[:value])
    elsif params[:instruction] == 'ask about'
      consumer.noRule!(params[:property], params[:value]) 
    else
      @error = 'invalid activity' 
    end
  
    respond_to do |format|  
      format.js     
    end
    
  end

  private
  
 def check_and_restore_payer_session    
   check_payer_session
   restore_payer_session    
  end

  def check_payer_session    
    unless session[:payer]  
      flash[:message] = "Please sign in with payer credentials"
      reset_session
      redirect_to  :controller => 'landing', :action => 'index'
    end 
  end  
  
  def restore_payer_session    
    @payer = session[:payer]            
    @consumer = session[:consumer]     
  end
  

end