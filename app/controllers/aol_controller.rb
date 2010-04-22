require 'ruby-debug'
require 'rubygems'
require 'seer'
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
    
    @payer = Payer.find(session[:payer_id])
    @rule = PayerRule.find(session[:rule_id])
    @auto_authorize_under = @rule.auto_authorize_under
    @auto_deny_over = @rule.auto_deny_over
    @manual_zone = @auto_deny_over - @auto_authorize_under
    @deny_zone = @auto_authorize_under * 1.5
    
    @back_to = "welcome_signedin"
    @back_class = "like_back"

    
  end
  
  def budget_form

    @rule = @payer.most_recent_payer_rule
    allowance = @rule.allowance
    balance = @payer.balance
    balance_position = (balance / allowance)*100
    tick = ((allowance / 40).floor)*10
    
    @uri = "http://chart.apis.google.com/chart?cht=gom&chs=300x120&chxt=y&chd=t:#{balance_position}&chl=Balance&chxr=0,0,#{allowance},#{tick}"
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
      redirect_to :action => :welcome_signedin
    else
      flash[:notice] = "Something wrong happened"
      redirect_to :action => :welcome_signedin
    end
    
  end
  
  def amounts_form                        
    
    @payer = Payer.find(session[:payer_id])
    @rule = PayerRule.find(session[:rule_id])
    @auto_authorize_under = @rule.auto_authorize_under
    @auto_deny_over = @rule.auto_deny_over
    @authorization_phone = @rule.authorization_phone
    
    @back_to = "rules_menu"
    @back_class = "like_back"

  end
  
  def fresh_amounts_form
    
  end
  
  def amounts_update                      # identicai to budget_update and possible others too - create method
    @payer =PayerRule.find(session[:rule_id])
    @rule = PayerRule.find(session[:rule_id])
    unless @rule
      flash[:notice] = "No rule set for this payer"
      redirect_to :action => :joinin
      return
    end
    
    @back_to = "rules_menu"
    @back_class = "like_back"

    if @rule.update_attributes(params[:rule])
      flash[:notice] = "Rule updated!"
#      render :action => :rules_menu, :target => "_webapp"
#      render :action => :amounts_form
    else
      flash[:notice] = "That doesn't make sense. Please check again!"
      render :action => :amounts_form
    end
 
end

def redirect_to_rules_menu
  
end

  def beinformed

    @categories = Category.all
    @balance = @payer.balance
    @pending = Purchase.pending_amt(@payer.id)
    
    @back_to = "welcome_signedin"
    @back_class = "like_back"


  end


  def authorization_form
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchase = Purchase.pending_trx(@payer.id)
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
    redirect_to :action => :welcome_signedin
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
  
  def purchases_by_product
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.by_product_title(params[:id])
    @i = 0
    render :action => :purchases
    
  end 

  def purchases_by_retailer
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    @purchases = Purchase.by_retailer_name(params[:id])
    @i = 0
    render :action => :purchases

     
  end
  
  def purchase
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"

    @purchase = Purchase.find(params[:id])  
    
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
  end
  
 end
