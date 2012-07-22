class AccountController < ApplicationController

  before_filter :check_and_restore_session, :except => [:login, :logout]

  def login       # (replace with Devise user based authentication)

  # ToDo: Get rid of session, once all app is RESTful

    if request.post?          
      if @payer = Payer.authenticate(params[:username], params[:password])
        session[:payer_id] = @payer.id
        redirect_to payer_purchases_path(@payer)
      else
        flash.now[:notice] = "Incorrect user or password. Please try again!"
      end      
    end         

  end
   
  def logout       # (replace with Devise user based authentication)

    reset_session
    redirect_to :controller => 'home', :action => 'index'

  end 
  
  def settings
    render 
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
  

end