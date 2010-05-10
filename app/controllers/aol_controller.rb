require 'ruby-debug'


include ActionView::Helpers::NumberHelper

class AolController < ApplicationController
  
  before_filter :assignments, :except => :amounts_update
  before_filter :authorize, :except => [:signin, :create, :welcome_new, :joinin]
 
  def main
    
  end
  def empty
    
  end
    
  def welcome_new

  end

  def welcome_signedin
     @pending_counter = Purchase.pending_cnt(@payer.id)
     params = nil
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
#        flash[:notice] = "Hi There!"
        redirect_to :action => :welcome_signedin
      else
        flash[:notice] = "No rule set for this payer"
        redirect_to :action => :joinin
      end
   end
   
  end
  
  def joinin
    
  end
  
  def create
    payer = Payer.new(params[:payer])
    payer.balance = 0
    payer.exists = true

    if payer.save
      session[:payer_id] = payer.id
      session[:payer_user] = payer.user                            # do I use it?
      rule = payer.payer_rules.create(:rollover => 0, :billing_id => 1, :auto_authorize_under => 10, :auto_deny_over => 100)
      session[:rule_id] = rule.id
      flash[:notice] = "Thank you. You may define your rules now"
      redirect_to :action => :welcome_signedin
    else
      redirect_to :action => "joinin"
    end

  end


  def account_form        
 
     begin
    @payer = Payer.find(session[:payer_id])
    rescue #RecordNotFound            # non needed, once i added the before_filter
    redirect_to :action => :welcome_new
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
    
    @rule = PayerRule.find(session[:rule_id])
    
    @back_to = "welcome_signedin"
    @back_class = "like_back"
    @help_to = "rules_help"
    
  end
  
  def rules_update                      # identicai to budget_update and possible others too - create method

    @rule = PayerRule.find(session[:rule_id])
   
    flash[:notice] = "That doesn't make sense. Please check again!" unless @rule.update_attributes(params[:rule])
    redirect_to :action => :welcome_signedin
    
    @back_to = "rules_menu"
    @back_class = "like_back"
 
end
  
  def rules_help
    
  end
  
  def involved_help
    
  end
  
  def content_menu
    
  end
  
  def budget_form

    @back_to = "welcome_signedin"
    @back_class = "like_back"
    
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
    
    @rule.update_attributes!(params[:rule])
    @payer.update_attributes!(params[:payer])
    

    redirect_to :action => :welcome_signedin
    
  end
  
  

def redirect_to_rules_menu
  
end

  def beinformed

    @categories = Purchase.payer_top_categories(@payer.id)
    @i = 0
    
    @back_to = "welcome_signedin"
    @back_class = "like_back"
    


  end


  def authorization_form
    
    @back_to = "/aol/purchases_pending_authorization"
    @back_class = "like_back"
    
    @purchase = Purchase.find(params[:id])
    if @purchase
      session[:purchase_id] = @purchase.id
      @retailer = Retailer.find(@purchase.retailer_id).name
      @product = Product.find(@purchase.product_id)
      @product_title = @product.title
      @category = @product.category.name
      @amount = @purchase.amount
      @date = @purchase.date.to_s(:long)
    else
      flash[:notice] = "There's nothing to authorize at this time"
      redirect_to :action => :welcome_signedin
    end
    
  end
  
  def authorization_update
    
    @purchase = Purchase.find(session[:purchase_id])
    @purchase.authorization_type = params[:purchase][:authorization_type]
    @purchase.authorization_date = Time.now if @purchase.authorization_type == ("ManuallyAuthorized" || "AlwaysAuthorized")
    @purchase.save
    # need to 
    # 1. move sms handling to an sms model
    # 2. put expected sms in the db, not in the session - so aaa will know what to expect
    # 3. send an sms either way, but include in it a rand number or not according to whether perm pin exists or not
    flash[:notice] = "Thank you!"
    params = nil
    redirect_to :action => :purchases_pending_authorization
  end

  def blacklist

    @blacklist = Purchase.never_authorized(@payer.id)
    @i = 0
     
    @back_to = "rules_menu"
    @back_class = "like_back"

  end

  def whitelist

    @whitelist = Purchase.always_authorized(@payer.id)
    @i = 0
    
    @back_to = "rules_menu"
    @back_class = "like_back"

  end

  def purchases
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.all
    @i = 0

    
  end
  
   def purchases_all
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.full_list(@payer.id)

    @i = 0
    render :action => :purchases
    
  end 
  
  def purchases_by_product
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.by_product_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
    
  end 

  def purchases_by_retailer
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.by_retailer_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
     
  end
  
  def purchases_pending_authorization_keep

    @back_to = "/aol/welcome_signedin"
    @back_class = "like_back"
    
    @purchases = Purchase.pending_trxs(@payer.id)
    
    @i = 0
    render :action => :purchases

  end

  def purchases_pending_authorization
    
    @back_to = "/aol/welcome_signedin"
    @back_class = "like_back"
    
    
    @pending = Purchase.pending_trxs(@payer.id)
    
    if request.post?

      # RAILS BUG MITIGATION - the returned params contain only those purchases that were NOT authorized
      @pending.each do |purchase|
        purchase.update_attributes(:authorization_type => "ManuallyAuthorized")
      end
      Purchase.update(params[:purchase].keys, params[:purchase].values) if params[:purchase]

      render :action => :welcome_signedin 
 
    end
    
  end
  
  def purchases_update
    
    render :action => :welcome_signedin
    
  end
  
  def purchase
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"

    @purchase = Purchase.find(params[:id]) 
    
    if @purchase.authorization_type == "ManuallyAuthorized"
      @authorization_text = "You approved it on " + @purchase.authorization_date.to_s(:long)
    elsif @purchase.authorization_type == "NotAuthorized" 
      @authorization_text = "You unapproved it on " + @purchase.authorization_date.to_s(:long)
    elsif @purchase.authorization_type == "ZeroBalance"
      @authorization_text = "Unapproved (Zero Balance)"
    elsif @purchase.authorization_type == "InsufficientBalance"
      @authorization_text = "Unapproved (Insufficient Balance)"
    elsif @purchase.authorization_type == "AutoUnder"
      @authorization_text = "Approved (Below Threshold)"
    elsif @purchase.authorization_type == "AutoOver"  
      @authorization_text = "Unapproved (Above Limit)"
    elsif @purchase.authorization_type == "NoPayer"
      @authorization_text = "Approved (No payer at the time)"
    else
      @authorization_text = "Approved"        # bug...
    end
   
    if @purchase.authentication_date.blank? or @purchase.authentication_type.blank? #just a case of incomplete test data
      @authentication_text = "Consumer was authenticated"
    else
      @autentication_text = "Consumer authenticated by " + @purchase.authentication_type + " on " + @purchase.authentication_date.to_s(:long) 
    end
    
    
  end
  
  def bills_form
    
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

 
  def help
    
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
  
  def assignments
    @back_class = "back"
    @help_to = "/aol/help"
  end
  
 end
