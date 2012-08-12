class HomeController < ApplicationController
 
  before_filter :check_and_restore_session, :except => [:index]

  def index  
  
  end  
  
  def routing_error
    
  end
  
end
