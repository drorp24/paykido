class MerchantController < ApplicationController

  
  def index
   redirect_to  :controller => 'subscriber', :action => 'index'    
  end
  

end
