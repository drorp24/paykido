
class WelcomeController < ApplicationController

 def index

    if request.post?
     
      @user = User.authenticate(params[:user][:name], params[:user][:password])
      if @user and @user.is_friend
        session[:friend_authenticated] = true
        redirect_to :controller => "subscriber", :action => "index"
      else
        session[:friend_authenticated] = false
        flash.now[:notice] = "Wrong user/pass combination. Please try again!"
      end
      
    end

    
  end
  

end
