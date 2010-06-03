include ActionView::Helpers::NumberHelper
class ServiceController < ApplicationController

  before_filter :check_payer_is_signedin, :only => :payer_signedin
  before_filter :check_retailer_is_signedin, :only => :retailer_signedin
  before_filter :check_administrator_is_signedin, :only => :administrator_signedin
  before_filter :check_general_is_signedin, :only => :general_signedin
  before_filter :set_environment, :except => [:index, :signin, :joinin, :signout]

  def joinin

    if request.post?
      
      @user = User.new(params[:user])
      @user.affiliation = "payer"
      @user.role = "primary"
      @user.payer = Payer.new(:balance => 0, :exists => true) 
     
      if @user.save
        session[:user] = @user     
        payer = @user.payer
        session[:payer] = payer                  
        rule = payer.payer_rules.create!(:rollover => false, :billing_id => 1, :auto_authorize_under => 10, :auto_deny_over => 50)
        session[:rule] = rule
        session[:payers_first_time] = true
        redirect_to :action => "payer_signedin"
      else
        if @user.errors.on(:name) == "has already been taken"
            flash.now[:notice] = "name is taken. Try a differet one!"
        elsif @user.errors.on(:password) == "doesn't match confirmation"
            flash.now[:notice] = "password/confirmation mismatch. Try again!"
        else
            flash.now[:notice] = "something's missing. Please try again!"
        end
      end
      
    end

  end
  
  def signin
    
   if request.post?
     
      @user = User.authenticate(params[:user][:name], params[:user][:password])
      unless @user
        flash.now[:notice] = "user or password are wrong. Please try again!"
        return
      end

      if @user.is_payer
        payer = @user.payer
        rule = payer.most_recent_payer_rule
        session[:payer] = payer
        session[:rule] = rule
        session[:user] = @user
        redirect_to :action => :payer_signedin
      elsif @user.is_retailer
        retailer = @user.retailer
        session[:retailer] = retailer
        session[:user] = @user
        redirect_to :action => :retailer_signedin
      elsif @user.is_administrator
        session[:user] = @user
        redirect_to :action => :administrator_signedin
      elsif @user.is_general
        session[:user] = @user
        redirect_to :action => :general_signedin
      else
        flash.now[:notice] = "User's type is unclear"      
     end
      
   end
   
  end
 
  def signout
    
    clear_session
    redirect_to :action => :index
    
  end

  def payer_signedin
        
    if session[:payers_first_time]        #reset it only after he's actually updated anything
      @message = "Thanks for joining us, #{@user.name}!\r\nSee how easy it is to define your rules:"
    else
      @message = ""
    end
    
  end
  
  def retailer_signedin
     
    @sales = Purchase.retailer_sales(@retailer.id)
        
    @categories = Purchase.retailer_top_categories(@retailer.id)
    @i = 0
     
  end
  
  def add_subscriber
    
    
    
  end
  
  def authenticate_subscriber
    
    #if provided the expected pin:
    
    consumer = Consumer.find_by_billing_phone(params[:consumer][billing_phone])
    if consumer
      consumer.update_attribtues()
    end
    
  end



  protected
  
  def check_payer_is_signedin
    
    unless session[:payer]
      flash[:message] = "Please sign in with payer credentials"
      clear_session
      redirect_to  :action => 'index'
    end
    
  end

  def check_retailer_is_signedin
    
    unless session[:retailer]
      flash[:message] = "Please sign in with retailer credentials"
      clear_session
      redirect_to  :action => 'index'
    end
    
  end
  
  def check_admininstrator_is_signedin
    
    unless session[:user] and session[:user].is_administrator
      flash[:message] = "Please sign in with administrator credentials"
      clear_session
      redirect_to  :action => 'index'
    end
    
  end
  
  def check_general_is_signedin
    
    unless session[:user] and session[:user].is_general
      flash[:message] = "Please sign in with general credentials"
      clear_session
      redirect_to :action => 'index'
    end
    
  end
 
  
  def set_environment
    @user =   session[:user]
    @payer =  session[:payer]
    @rule =   session[:rule]
    @retailer=session[:retailer]
  end


# delete this section after i tested i dont need them  
#  def find_user
#    session[:user]||= User.new
#  end
  
#  def find_payer   
#    session[:payer]||=Payer.new
#  end
  
#  def find_rule    
#    session[:rule] ||= @payer.most_recent_payer_rule
#  end
  
#  def find_retailer    
#    session[:retailer]||=Retailer.new
#  end
  
  def clear_session
    session[:user] = session[:payer] = session[:rule] = session[:retailer] = session[:payers_first_time] = nil
  end
  
end
