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
    if params[:id] != "0"
      @consumer_added = Consumer.added(params[:id])
      @consumers << @consumer_added
      session[:consumers] = @consumers
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def retailers
    
    @retailers = session[:retailers]
    
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
    session[:consumers] = @consumers 
    flash[:message] = "Welcome to arca!" if @consumers.empty?
    
    @retailers = Purchase.payer_retailers_the_works(@payer.id)
    session[:retailers] = @retailers
    session[:retailer] = (@retailers.empty?) ?nil :@retailers[0]

  end
 
  def allowance

    find_consumer
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end

  end
  
  def approvals
    
    find_consumer
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end

    
  end
  
  def retailer
    
    @retailer = session[:retailers].select{|retailer| retailer.id == params[:id].to_i}[0]
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def consumer_update
    
    consumer = session[:consumer]
    consumer.update_attributes!(:name => params[:name])
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def consumer_rules_update
    
    @consumer = session[:consumer]                  # check if this line and the next can be removed
    @payer_rule = session[:payer_rule]
    @consumer.update_attributes!(params[:consumer]) if params[:consumer] and @consumer.balance != params[:consumer][:balance]
    @payer_rule.update_attributes!(params[:payer_rule]) 
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def payment_update
    
    unless @payer.update_attributes(params[:payer])
      flash[:notice] = "Invalid phone number. Please try again!"
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end
    
  end
  
  def rlist_update
    

   @rlist = Rlist.find_or_initialize_by_payer_id_and_retailer_id(@payer.id, params[:id])
    unless @rlist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Oops... server unavailble. Back in a few moments!"
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
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
    @payer_rule = session[:payer_rule]
    
    if @consumer.payer_id                       # case of repeating the submit button after the consumer has been linked
        flash[:notice] = "Phone is already assigned to you!"
        @phone = nil
        respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
        end         
    else
        find_def_payer_rule
        @consumer.update_attributes!(:payer_id => @payer.id, :balance => @def_payer_rule.allowance, :name => "(key name here)")
        @phone = @consumer.billing_phone
        session[:consumer] = @consumer
        session[:payer_rule] = @consumer.payer_rules.create!(:allowance => @def_payer_rule.allowance, :rollover => @def_payer_rule.rollover, :auto_authorize_under => @def_payer_rule.auto_authorize_under, :auto_deny_over => @def_payer_rule.auto_deny_over)
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
  
  def find_consumer
    
    if session[:consumer] and session[:consumer].id == params[:id]
      @consumer = session[:consumer]
      @payer_rule = session[:payer_rule]
    elsif params[:id] and params[:id] != "0"
      @consumer = Consumer.find(params[:id])            # CHANGE THIS to fetch from the array instead of DB (as in find_retailer)
      @payer_rule = @consumer.most_recent_payer_rule
    else      # params[:id] == 999 (indicating a blank consumer)
      @consumer = init_consumer
      @payer_rule = init_payer_rule
    end
   
    session[:consumer] = @consumer
    session[:payer_rule] = @payer_rule
    
  end
  
  def init_consumer
    Consumer.new(:balance => 0)
  end
  
  def init_payer_rule
    PayerRule.new(:allowance => 0, :rollover => false, :auto_authorize_under => 0, :auto_deny_over => 1)
  end
    
  
  def find_def_payer_rule
    
    @def_payer_rule = PayerRule.find_by_payer_id(@payer.id)
    
    @def_payer_rule ||= init_payer_rule 
    
  end
 
  
  def set_environment
    
    @user =   session[:user]
    @payer =  session[:payer]
    @payer_rule =   session[:payer_rule]
    @retailer = session[:retailer]
    @consumer = session[:consumer]

  end


  def clear_session
    session[:user] = session[:payer] = session[:consumer] = session[:consumers] = session[:payer_rule]  = 
    session[:retailer] = session[:expected_pin] = nil
  end
  
end
