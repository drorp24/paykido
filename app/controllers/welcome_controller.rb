
class WelcomeController < ApplicationController

 def index

    if request.post?
     
      @user = User.authenticate(params[:user][:name], params[:user][:password])
      if @user and @user.is_friend
        redirect_to :controller => "service", :action => "index"
      else
        flash.now[:notice] = "Wrong user/pass combination. Please try again!"
      end
      
    end

    
  end
  

end
