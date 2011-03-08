class PlayController < ApplicationController

  before_filter   :check_friend_authenticated    

  
  def index
  end
  def check_friend_authenticated    
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  

end
