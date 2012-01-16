class ServiceController < ApplicationController

#   before_filter   :check_friend_authenticated    

  
  def index 
        
  end
  
  def keep_sc_success
    # indicate 'registered' on the payer record and record the sc token on a new payer field
    # redirect him to his prepared account if there is, with a message that he's succesfully registered
    # call the kid to inform registration has been completed
    
    @status = params[:Status]
    @amount = params[:totalAmount]
    @code = params[:ErrCode]
    @reason = params[:Reason]
    @token = params[:Token]
  end
  
  def keep_sc_error
    @status = params[:Status]
    @amount = params[:totalAmount]
    @code = params[:ErrCode]
    @reason = params[:Reason]
    @token = params[:Token]   
  end
  
  def sc_success
    flash[:message] = "Congratulations! You are registered to Paykido!"
    redirect_to  :controller => "subscriber", :action => "payer_signedin"
  end
 
  
  def check_friend_authenticated 
    session[:req_controller] = params[:controller]
    session[:req_action] = params[:action]
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  

  def clear_payer_session
    session[:user] = session[:payer] =
    nil
  end

end
