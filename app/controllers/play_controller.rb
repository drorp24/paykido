class PlayController < ApplicationController

  before_filter   :check_friend_authenticated    

  
  def index  
    session[:consumer] = nil
    @activity = session[:activity]    
  end
  
  def check_friend_authenticated 
    session[:req_controller] = params[:controller]
    session[:req_action] = params[:action]
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  

end
