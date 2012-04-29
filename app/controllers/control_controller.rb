class ControlController < ApplicationController

# 3 types of activities:
# => full page (e.g., control/dashboard)  triggered by sub-menu     return html   (default render)      ajax by Spina
# => pane replace (e.g., purchase)        trigered by link on page  return html   render layout false   ajax by me
# => update act(e.g., approve, whitelist) triggered by by button    return js     format js             ajax by me



  before_filter :check_and_restore_payer_session, :except => [:login, :logout]

  def login
    
    if request.post?
           
      if session[:payer] = Payer.authenticate(params[:username], params[:password])
        redirect_to :action => 'dashboard'
      else
        flash.now[:notice] = "Incorrect user or password. Please try again!"
      end
      
    end
          
  end
   
  def logout
    
  end 
  
  def dashboard

    @purchases = Purchase.where("payer_id = ?", @payer.id).includes(:consumer, :retailer)
    @pendings = @purchases.where("authorization_type = ?",'PendingPayer')
    @pendings_count = @pendings.count

    @purchase = Purchase.find(446) # Temporary. Should be @pendings[0]
    @consumer = @purchase.consumer                    

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
    end
    
  end
  
  def purchase
    
    @purchase = Purchase.find(params[:id])

    render :layout => false
    
  end
  
  def set_rule
    
    consumer = Consumer.find(params[:consumer])   
    consumer.set_rule!(params[:property], params[:value], params[:rule])
  
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