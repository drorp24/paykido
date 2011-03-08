
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
    
    @use_jqt = "no"

    @categories = Purchase.payer_top_categories(@payer.id)
    @i = 0
    
    @back_to = "welcome_signedin"
    @back_class = "like_back"
    


  end

  
  def purchases
    
   @use_jqt = "no"
    
#    @back_to = "/aol/beinformed"
#    @back_class = "like_back"
    
#    @purchases = Purchase.all
#    @i = 0

    
  end
  
   def purchases_all
     
    @use_jqt = "no"    
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    session[:prev_action] = "purchases_all"
    session[:prev_id] = nil

    
    @purchases = Purchase.full_list(@payer.id)

    @i = 0
    render :action => :purchases
    
  end 
  
  def purchases_by_product
    
    @use_jqt = "no"
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    session[:prev_action] = "purchases_by_product"
    session[:prev_id] = params[:id]
    
    @purchases = Purchase.by_product_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
    
  end 

  def purchases_by_retailer
    
    @use_jqt = "no"
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    session[:prev_action] = "purchases_by_retailer"
    session[:prev_id] = params[:id]

    
    @purchases = Purchase.by_retailer_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
     
  end
  

  def purchases_pending_authorization
    
    @use_jqt = "no"
    
    @back_to = "/aol/welcome_signedin"
    @back_class = "like_back"
    
    session[:prev_action] = "purchases_pending_authorization"
    session[:prev_id] = nil    
    
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
    
    @use_jqt = "no"
    
    @back_to = session[:prev_action] + '/' +  session[:prev_id]
    @back_class = session[:prev_id]

    @purchase = Purchase.find(params[:id]) 
    session[:purchase_id] = @purchase.id

    @retailer = @purchase.retailer
    @product = @purchase.product
    @category = @purchase.product.category
    
    @rlist = @retailer.rlist(@payer.id)
    @plist = @product.plist(@payer.id)
    @clist = @category.clist(@payer.id)
    
    @authorization = nil
    if @purchase.authorization_type == "PendingPayer"
      @authorization_text = 
            [["Authorize this","ManuallyAuthorized"],
             ["Unauthorize this " , "Unauthorized"]]
    elsif @purchase.authorization_type == "ManuallyAuthorized"
      @authorization_text = ["Authorized by you on #{@purchase.authorization_date.to_s(:long)}"]
    elsif @purchase.authorization_type == "Unauthorized" 
      @authorization_text = ["Unauthorized by you on  #{@purchase.authorization_date.to_s(:long)}"]
    else
      @authorization = "by arca"
    end
    
    
  end
  
  def purchase_update
    
    
    # need to 
    # 1. move sms handling to an sms model
    # 2. put expected sms in the db, not in the session - so consumer will know what to expect
    # 3. send an sms either way, but include in it a rand number or not according to whether perm pin exists or not
    
    @purchase = Purchase.find(session[:purchase_id])
    @retailer = @purchase.retailer
    @product = @purchase.product
    @category = @purchase.product.category
    
        
    if params[:purchase] and 
       params[:purchase][:authorization_type] != @purchase.authorization_type and
      (params[:purchase][:authorization_type] == "ManuallyAuthorized" or 
      params[:purchase][:authorization_type] == "Unauthorized")
      @purchase.authorization_type = params[:purchase][:authorization_type]
      @purchase.authorization_date = Time.now 
      @purchase.save      
    end
    

    if params[:rlist] and (params[:rlist] != @retailer.status(@payer.id))
      @retailer.update(@payer.id, params[:rlist][:status])
    end 
    if params[:plist] and (params[:plist] != @product.status(@payer.id))
      @product.update(@payer.id, params[:plist][:status])
    end 
    if params[:clist] and (params[:clist] != @category.status(@payer.id))
      @category.update(@payer.id, params[:clist][:status])
    end 
    

    redirect_to :action => session[:prev_action], :id => session[:prev_id]
    
  end
  
  def arca_auth_help
    
    @purchase = Purchase.find(session[:purchase_id])
    @rule = PayerRule.find(session[:rule_id])
    
    @back_to = "/aol/purchase/#{@purchase.id}"
    @back_class = "like_back"

    
    @rule_left = "blah blah "
    @rule_right = "blah blah "
    @variable = "blah blah "
    @auth_ind = "blah blah "

    
    if @purchase.authorization_type == "ZeroBalance"
      @authorization_text = "Unauthorized: Zero Balance"
    elsif @purchase.authorization_type == "InsufficientBalance"
      @authorization_text = "Unauthorized: Insufficient Balance"
    elsif @purchase.authorization_type == "AutoUnder"
      @authorization_text = "Authorized: Below Threshold"
      @rule_left = "anything under "
      @rule_right = "can be authorized"
      @variable = "the purchase price was "
      @auth_ind = "authorized"
    elsif @purchase.authorization_type == "AutoOver"  
      @authorization_text = "Unauthorized: Above Limit"
    elsif @purchase.authorization_type == "NoPayer"
      @authorization_text = "Authorized: No payer"
    elsif @purchase.authorization_type == "Blacklisted"
      @authorization_text = "Unauthorized: Blacklisted"
    elsif @purchase.authorization_type == "Whitelisted"
      @authorization_text = "Authorized: Whitelisted"
    else
      @authorization_text = "Authorized: Other"
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
