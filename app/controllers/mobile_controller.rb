class MobileController < ApplicationController

  
  def index
   redirect_to  :controller => 'aol', :action => 'signin'    
  end
  

end
