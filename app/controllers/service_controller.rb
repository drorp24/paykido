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
      @user.payer = Payer.new(:balance => 0, :exists => true, :billing_id => 1) 
     
      if @user.save
        session[:user] = @user     
        payer = @user.payer
        session[:payer] = payer                  
        payer_rule = payer.payer_rules.create!(:allowance => 0, :rollover => false, :billing_id => 1, :auto_authorize_under => 10, :auto_deny_over => 25)
        session[:payer_rule] = payer_rule
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
      if @user
        session[:user] = @user
      else
        flash.now[:notice] = "user or password are incorrect. Please try again!"
        return
      end

      if @user.is_payer
        session[:payer] = @user.payer
        session[:payer_rule] = @user.payer.most_recent_payer_rule
        redirect_to :action => :payer_signedin
      elsif @user.is_retailer
        session[:retailer] = @user.retailer
        redirect_to :action => :retailer_signedin
      elsif @user.is_administrator
        redirect_to :action => :administrator_signedin
      elsif @user.is_general
        redirect_to :action => :general_signedin
      else
        flash.now[:notice] = "User's type is not clear"      
     end
      
   end
   
  end
 
  def signout
    
    clear_session
    redirect_to :action => :index
    
  end


  def consumers
    
    @consumer = session[:consumer]
    @consumers = session[:consumers]
    @consumers_counter = session[:consumers_counter]
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def payer_signedin
        
    @consumers = all = []
    
    all = Consumer.who_purchased_or_not(@payer.id)
    unless all.empty?
      purchased = Consumer.who_purchased(@payer.id, Time.now.strftime('%m'))  
      didnt_purchase = all - purchased
      @consumers = purchased + didnt_purchase                                 
    end
    
    if @consumers.empty?
      flash[:message] = "Welcome to arca!" 
      @consumer = Consumer.new
      session[:consumers] = nil
      session[:consumers_counter] = 0
    else
      @consumer = @consumers[0] 
      session[:consumers] = @consumers    
      session[:consumers_counter] = @consumers.size
    end
    session[:consumer] = @consumer
    
  end
 
  def allowance

    if session[:consumer] and session[:consumer].id == params[:id]
      @consumer = session[:consumer]
      @consumer_rules = session[:consumer_rules]
    else
      @consumer = Consumer.find(params[:id])
      @consumer_rules = @consumer.most_recent_payer_rule
      session[:consumer] = @consumer
      session[:consumer_rules] = @consumer_rules
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end

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
      @consumer.balance = @payer_rule.allowance
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
    @consumer = session[:consumer]
    
    unless session[:phone_is_ok]
      flash[:notice] = "Please handle the phone number first"
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
        @consumer.update_attributes!(:payer_id => @payer.id, :balance => @payer_rule.allowance)
        session[:consumer] = @consumer
        session[:consumer_rules] = @consumer.payer_rules.create!(:allowance => @payer_rule.allowance, :rollover => @payer_rule.rollover, :auto_authorize_under => @payer_rule.auto_authorize_under, :auto_deny_over => @payer_rule.auto_deny_over)
        session[:consumers] = session[:consumers] << @consumer
        @consumers = session[:consumers]
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
    @payer_rule =   session[:payer_rule]
    @retailer = session[:retailer]
    @consumer = session[:consumer]
    @consumer_rule =  session[:consumer_rule]

  end


  def clear_session
    session[:user] = session[:payer] = session[:payer_rule] = session[:consumer] = session[:consumer_rule]  = session[:retailer] = 
    session[:expected_pin] = session[:consumers_counter] = nil
  end
  
end
