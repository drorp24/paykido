class AccountController < ApplicationController

  before_filter :check_and_restore_session, :except => [:login, :logout, :access]


  def login       # (replace with Devise user based authentication)

    if request.post?          
      if session[:payer] = Payer.authenticate(params[:username], params[:password])
        redirect_to purchases_path
      else
        flash.now[:notice] = "Incorrect user or password. Please try again!"
      end      
    end         

  end
   
  def logout       # (replace with Devise user based authentication)

    reset_session
    redirect_to :controller => 'home', :action => 'index'

  end 
  
  def access       # (replace with Devise token-based authentication)     

    if @payer = Payer.authenticate_by_token(params[:email], params[:token])
      session[:payer] = @payer
      redirect_to :action => 'dashboard', :consumer => params[:consumer], :activity => params[:activity] #action should also be a parameter
    else
      reset_session
      flash[:notice] = "Incorrect user or password. Please try again!"
      redirect_to :action => 'login'
    end  

  end   

  def consumer_confirm      

    @consumer.confirm!
     
    respond_to do |format|  
      format.js
    end
    
  end

  def consumer_allowance_change
    
    @consumer.allowance_change!(params[:consumer])        

    respond_to do |format|  
      format.js
    end
    
  end
  
  def consumer_rule_set
    
    @consumer.rule_set!(params)
  
    respond_to do |format|  
      format.js     
    end
    
  end

  def purchase
    
    @purchase = Purchase.find(params[:id])

    render :partial => 'purchase_details', :layout => false
    
  end
  

  private
  
  def check_and_restore_session  
 
    unless session[:payer]            # replace with Devise  
      flash[:message] = "Please sign in with payer credentials"
      reset_session
      redirect_to  :controller => 'home', :action => 'index'
      return
    end
        
    @payer = session[:payer]            

    #once I switch to RESTful controllers, params[:id] would be the id of the right resource
    if params[:id]
      @consumer = Consumer.find(params[:id])
    elsif params[:consumer]
     @consumer = Consumer.find(params[:consumer])
    else
      @consumer = nil     
    end
    session[:consumer] = @consumer
    
    if params[:purchase] 
      @purchase = Purchase.find(params[:purchase])
    elsif session[:purchase]
      @purchase = session[:purchase]
    elsif @consumer
      @purchase = @consumer.purchases.first
    else
      @purchase = @payer.purchases.first         
    end
    session[:purchase] = @purchase
    
  end  

end