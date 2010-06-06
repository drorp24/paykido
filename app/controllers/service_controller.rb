include ActionView::Helpers::NumberHelper
require 'rubygems'
require 'clickatell'

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
        flash.now[:notice] = "user or password are incorrect. Please try again!"
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
        
    @consumers = Consumer.find_all_by_payer_id(@payer.id)
    session[:consumers_counter] = @consumers.size
   
  end
  
  def retailer_signedin
     
    @sales = Purchase.retailer_sales(@retailer.id)
        
    @categories = Purchase.retailer_top_categories(@retailer.id)
    @i = 0
     
  end
  
  def sms_consumer
    

    @consumer = Consumer.find_or_initialize_by_billing_phone(params[:consumer][:billing_phone])
    if @consumer.invalid?
      session[:phone_is_ok] = false
      flash[:notice] = "Invalid phone number. Please try again!"
      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end
    elsif @consumer.payer_id.to_i == @payer.id
      session[:phone_is_ok] = false
      flash[:notice] = "Phone is already assigned to you!"
      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end
    elsif @consumer.id
      session[:phone_is_ok] = false
      flash[:notice] = "That phone is assigned to someone else"
      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end
    else
      session[:phone_is_ok] = true
      session[:consumer] = @consumer
      session[:expected_pin] = rand.to_s.last(4)
      sms(@consumer.billing_phone,"your PIN code is: #{session[:expected_pin]}")
      flash[:notice] = "Thank you. A text message with the PIN code is on its way!"
      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end 
    end
    
    
  end
        
  
  def sms(phone, message)

#    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
#    api.send_message('0542343220', message)
    
  end
   
  
  def check_pin_and_link_consumer
    
    @consumers_counter = session[:consumers_counter]
    
    unless session[:phone_is_ok]
      flash[:notice] = "Please key-in proper phone number and wait for the text message"
      @phone = nil
      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end 
      return
    end
   
       
    if params[:consumer][:pin] != session[:expected_pin]
        flash[:notice] = "Incorrect PIN code [#{session[:expected_pin]}]. Please try again!"
        @phone = nil
        respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
        end
        return
    end
    
        
    @consumer = session[:consumer]
    
    if @consumer.payer_id                       # case of repeating the submit button after the consumer has been linked
        flash[:notice] = "Phone is already assigned to you!"
        @phone = nil
        respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
        end         
    else
        @consumer.update_attributes!(:payer_id => @payer.id)
        @consumers_counter += 1
        session[:consumers_counter] = @consumers_counter   
        @phone = @consumer.billing_phone
        flash[:message] = "Thank you. #{number_to_phone(@phone, :area_code => true)} is now assigned to you!"
 
        respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
        end
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
    session[:user] = session[:payer] = session[:rule] = session[:consumer] = session[:retailer] = 
    session[:expected_pin] = session[:consumers_counter] = nil
  end
  
end
