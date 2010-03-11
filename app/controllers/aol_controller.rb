require 'ruby-debug'
require 'rubygems'
require 'seer'
class AolController < ApplicationController
  
  before_filter :authorize, :except => [:signin, :welcome_new, :joinin]
  def main
    
  end
    
  def welcome_new

  end

  def welcome_signedin
    
  end
  
  def signin
    
   if request.post?

      payer = Payer.authenticate(params[:payer][:user], params[:payer][:password])
      unless payer
        flash[:notice] = "Invalid user/password combination"
        return
      end
      rule = payer.most_recent_payer_rule
      if rule
        session[:payer_id] = payer.id
        session[:payer_user] = payer.user                         # do I use it?
        session[:rule_id] = rule
        flash[:notice] = "Hi There!"
        redirect_to :action => :welcome_signedin
      else
        flash[:notice] = "No rule set for this payer"
        redirect_to :action => :joinin
      end
   end
   
  end
  
  def joinin
    @payer = Payer.new(:exists => true, :balance => 0)
    
  end
  
  def create
    payer = Payer.new(params[:payer])
#    payer.balance = 0                    # should be set to 0 already by joinin. Also check exists is set.

    if payer.save
      session[:payer_id] = payer.id
      session[:payer_user] = payer.user                            # do I use it?
      rule = payer.payer_rules.create(:rollover => 0, :billing_id => 1)
      session[:rule_id] = rule.id
      flash[:notice] = "Thank you. You may define your rules now"
      redirect_to :action => :welcome_signedin
    else
      render :action => "joinin"
    end

  end

  def account_form        # decide if I want a rescue like this in other activities or assume you never start here
    
    begin
    @payer = Payer.find(session[:payer_id])
    rescue #RecordNotFound
    redirect_to :action => :welcome_new
    else
    flash.now[:notice] = "You can change any of the following:"
    end
  
  end 
 
  def account_update
    payer = Payer.find(session[:payer_id])
    
    if payer.update_attributes(params[:payer]) 
      flash[:notice] = "Thank you"
      redirect_to :action => :welcome_signedin
    else
      render :action => "account_form"
    end
  end
  
  def rules_menu
    
  end
  
  def budget_form
    @payer = Payer.find(session[:payer_id])
    @rule = @payer.most_recent_payer_rule
  end
  
  def budget_update
    
    @payer = Payer.find(session[:payer_id])
    @rule = PayerRule.find(session[:rule_id])
    unless @rule
      flash[:notice] = "No rule set for this payer"
      redirect_to :action => :joinin
      return
    end
    
    if @rule.update_attributes(params[:rule])

      flash[:notice] = "Rule updated!"
      redirect_to :action => :rules_menu
    else
      flash[:notice] = "Something wrong happened"
      render :action => :rules_menu
    end
    
  end
  
  def amounts_form                        # make it graphical one day
    
    @payer = Payer.find(session[:payer_id])
    @rule = PayerRule.find(session[:rule_id])
    
  end
  
  def amounts_update                      # identicai to budget_update and possible others too - create method
    @payer =PayerRule.find(session[:rule_id])
    @rule = PayerRule.find(session[:rule_id])
    unless @rule
      flash[:notice] = "No rule set for this payer"
      redirect_to :action => :joinin
      return
    end
    
    if @rule.update_attributes(params[:rule])

      flash[:notice] = "Rule updated!"
      redirect_to :action => :rules_menu
    else
      flash[:notice] = "Something wrong happened"
      render :action => :rules_menu
    end
 
  end

  def beinformed

    @categories = Category.all
    @balance = @payer.balance
    @pending = Purchase.pending_amt(@payer.id)

  end


  def authorization_form
    
    @purchase = Purchase.pending_trx(@payer.id)
    if @purchase
      session[:purchase_id] = @purchase.id
      @retailer = Retailer.find(@purchase.retailer_id).name
      @product = Product.find(@purchase.product_id).title
      @amount = @purchase.amount
      @date = @purchase.date.to_s(:long)
    else
      flash[:notice] = "There's nothing to authorize at this time"
      redirect_to :action => :beinformed
    end
    
  end
  
  def authorization_update
    
    @purchase = Purchase.find(session[:purchase_id])
    @purchase.authorization_date = Time.now
    @purchase.authorization_type = "ManuallyAuthorized"
    @purchase.save
    # need to 
    # 1. move sms handling to an sms model
    # 2. put expected sms in the db, not in the session - so aaa will know what to expect
    # 3. send an sms either way, but include in it a rand number or not according to whether perm pin exists or not
    flash[:notice] = "Purchase authorized. Thank you!"
    redirect_to :action => :beinformed
  end
  
    def send_sms_to_consumer
    
      sms_phone = @consumer.billing_phone
      sms_message = "your PIN code is: #{session[:expected_pin]}"
      sms(sms_phone,sms_message)
      
  end
        
  
  def sms(phone, message)

#    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
#    api.send_message('0542343220', message)
    
  end

 
   def logout
    session[:payer_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
  
  
  protected
  
  def authorize
    
    @payer = Payer.find_by_id(session[:payer_id])
    unless @payer
      flash[:notice] = "Please log in"
      redirect_to :controller => 'aol' , :action => 'signin'
    end
    
  end
  
 end
