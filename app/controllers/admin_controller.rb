class AdminController < ApplicationController

#   before_filter   :check_friend_authenticated    

  def populate_title
    Purchase.all.each {|purchase| purchase.update_attributes!(:title => 'farmville')}
    redirect_to :action => :index 
  end

  def set_allowance_every
    Consumer.all.each {|consumer| 
      if consumer.allowance_period == 'Monthly'
        consumer.update_attributes!(:allowance_every => 1)
      elsif consumer.allowance_period == 'Weekly'
        consumer.update_attributes!(:allowance_every => 0)
      end
      }
     redirect_to :action => :index 
  end

  def retailers    
    @retailers =  Purchase.payer_retailers_the_works(63)
    redirect_to :action => :index 
  end


  def set_category_to_1
    Purchase.all.each {|p| p.update_attributes!(:category_id => 1)}
    redirect_to :action => :index 
  end

  def return_to_pending
    Purchase.where(:payer_id => 63, :authorization_type => 'ManuallyAuthorized').each  do |p|
      p.authorized = false
      p.require_manual_approval!
    end
    redirect_to :action => :index 
  end

  def set_payer_to_not_registered
    payer = Payer.find(63)
    payer.update_attributes!(:registered => false)
    redirect_to :action => :index 
  end

  def cut_authorization_type
    
    Purchase.all.each do |p|
      if p.authorization_type
        first = p.authorization_type.split(' ')[0]
        second = p.authorization_type.split(' ')[1]
        if first and second
          updated_type = first + ' ' + second
          p.update_attributes!(:authorization_type => updated_type)          
        end        
      end
    end
    
    redirect_to :action => :index 
    
  end
  
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
