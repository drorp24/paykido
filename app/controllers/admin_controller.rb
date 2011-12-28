class AdminController < ApplicationController

#   before_filter   :check_friend_authenticated    

  
  def balance_test
    consumer = Consumer.find(1007)
    consumer.update_attributes!(params[:consumer])
    redirect_to :action => :index    
  end

  def index  
  end
  
  def allowance_update
    Consumer.all.each do |consumer|
      
      consumer.update_attributes!(
        :allowance => params[:consumer][:allowance],
        :allowance_period => params[:consumer][:allowance_period],
        :allowance_change_date => params[:consumer][:allowance_change_date],
        :balance_on_acd => 0,
        :purchases_since_acd => 100,
        :auto_authorize_under => 0,
        :auto_deny_over => 50
      )
    end
    
    redirect_to :action => :index
  end
  
  def update_all_to_monthly
    Consumer.all.each do |consumer|
      consumer.update_attributes!(:allowance_period => "Monthly")
    end    
    redirect_to :action => :index
  end
  
  def check_friend_authenticated 
    session[:req_controller] = params[:controller]
    session[:req_action] = params[:action]
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end
  

end
