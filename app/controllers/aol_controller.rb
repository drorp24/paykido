require 'rubygems'
require 'clickatell'

include ActionView::Helpers::NumberHelper

class AolController < ApplicationController
  
  before_filter :assignments, :except => :amounts_update
  before_filter :authorize, :except => [:signin, :create, :welcome_new, :joinin]
 
  def check_for_new_pendings
    
    @pending_count = Purchase.pending_count(@payer.id)
    if @pending_count != 0 and @pending_count != session[:pending_count]
      session[:pending_count] = @pending_count
      @new_pendings = true
    end

  respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
  end
  
  end
  
  def main
    
  end
  def empty
    
  end
    
  def welcome_new

  end

  def welcome_signedin
    
     @pending = Purchase.pending_cnt(@payer.id)
     @pending_counter = @pending[0]
     @purchase_id = @pending[1]
     
     if @pending_counter == 1
       session[:prev_action] = nil
       session[:prev_id] = nil
     end
 
  end
  
  def signin
    
   if request.post?

      user = User.authenticate(params[:user][:name], params[:user][:password])
      unless user
        flash.now[:notice] = "Invalid user/password combination. Try again!"
        return
      end
      unless user.is_payer
        flash.now[:notice] = "Invalid user/password combination. Try again!"
        return
      end
      payer = user.payer
      session[:payer] = payer
      session[:user] = user
      redirect_to :action => :welcome_signedin
    
   end
   
  end
  
#  def joinin

#    @user = find_user
    
#  end
  
#  def create

#    user = User.new(params[:user])
#    user.affiliation = "payer"
#    user.role = "primary"
#    user.payer = Payer.new(:balance => 0, :exists => true) 
#    session[:user] = user     
    
#    if user.save
#      payer = user.payer
#      session[:payer] = payer                  
#      payer_rule = payer.payer_rules.create!(:rollover => false, :auto_authorize_under => 10, :auto_deny_over => 50)
#      session[:payer_rule] = payer_rule
#      flash[:notice] = "Thanks for joining us. Enjoy!"
#      redirect_to :action => :welcome_signedin
#    else
#      if user.errors.on(:name) == "has already been taken"
#          flash[:notice] = "Sorry... name is taken. Try a differet one!"
#      elsif user.errors.on(:password) == "doesn't match confirmation"
#          flash[:notice] = "Oops... password doesn't match its confirmation. Please try again!"
#      else
#          flash[:notice] = "Oops... something's missing. Try again!"
#      end
#      redirect_to :action => "joinin"
#    end

#  end


  def account_form        
 
    @user = find_user
    @payer = session[:payer]
  
  end 
 
  def account_update
    payer = session[:payer]
    
    if payer.update_attributes(params[:payer]) 
      redirect_to :action => :welcome_signedin
    else
      render :action => "account_form"
    end
  end
  
  def rules_menu
    
    @use_jqt = "no"
    @back_to = "/aol/select_consumer/rules_menu"
    @back_class = "like_back"    
    @help_to = "/aol/rules_help"
    
    if params and params[:id]
      @consumer = Consumer.find(params[:id])
    else
      @consumer = session[:consumer]
    end
    
    session[:consumer] = @consumer
    @consumer_rule = @consumer.most_recent_payer_rule
    session[:consumer_rule] = @consumer_rule
      
  end
  
  def rules_update                      # identicai to budget_update and possible others too - create method

    @consumer_rule = session[:consumer_rule]
   
    unless @consumer_rule.update_attributes(params[:consumer_rule])
      flash[:notice] = "That doesn't make sense. Please check again!"
      redirect_to :action => :rules_menu
      return
    end
        
    redirect_to :action => :select_consumer, :id => "rules_menu"
  
  end
  
  def rules_help
    
    @back_to = "/aol/rules_menu"
    @back_class = "like_back"
    
  end
  
  def involved_help

    @back_to = "/aol/rules_menu/#{session[:consumer].id}"
    @back_class = "like_back"    
    
  end
  
  def sms_prefs
    
  @back_to = "/aol/rules_menu"
  @back_class = "like_back"
   
  end
  
  def sms_update
    
    unless @payer.update_attributes(params[:payer])
      flash[:notice] = "That doesn't make sense. Please check again!"
      redirect_to :action => :sms_prefs
      return
    end
  
    redirect_to :action => :rules_menu
 
  end
  
  def email_prefs
    
  @back_to = "/aol/rules_menu"
  @back_class = "like_back"
  
  @email_frequencies =
            [["as the event occurs","as it occurs"],
             ["once a day" , "once a day"],
             ["on a weekly basis", "on a weekly basis"],
             ["once a month", "once a month"]]
   @email_events =
            [["manual authorization" , "manual authorization"],
             ["periodical activity digests" , "periodical digests"],
             ["reports & statistics" , "reports and stats"],
             ["offers & promotions", "offers and promos"]]            
    
  end
  
  def email_update
    
     unless @payer.update_attributes(params[:payer])
      flash[:notice] = "That doesn't make sense. Please check again!"
      redirect_to :action => :email_prefs
      return
    end
  
    redirect_to :action => :rules_menu
 
  end   

  def content_menu
    
  end
  
  def retailers
    
    @retailers = Purchase.payer_retailers(@payer.id)
    
  end
  
  def products
    
    @products = Purchase.payer_products(@payer.id)
    
  end
  
  def categories
    
    @categories = Purchase.payer_categories(@payer.id)
    
  end
  
  def select_consumer
    
    @back_to = "/aol/welcome_signedin"
    @back_class = "like_back"
    
    @action = params[:id]
    @title = (@action == 'budget_form') ?"Allowance":"Authorization" 
    
    @consumers = Consumer.find_all_by_payer_id(@payer.id)
    
  end
  
  def budget_form

#    @use_jqt = "no"
#    @back_to = "/aol/select_consumer/budget_form"
#    @back_class = "like_back"    

    
    @consumer = Consumer.find(params[:id])
    session[:consumer] = @consumer
    @consumer_rule = @consumer.most_recent_payer_rule
    session[:consumer_rule] = @consumer_rule

  end
  
  def budget_update
  
    @use_jqt = "no"
    
    @consumer = session[:consumer]
    @consumer_rule = session[:consumer_rule]
    unless @consumer_rule
      flash[:notice] = "No rule set for this consumer"
      redirect_to :action => :joinin
      return
    end    
    
    @consumer_rule.update_attributes!(params[:consumer_rule])
    @consumer.update_attributes!(params[:consumer])   

    redirect_to :action => :select_consumer, :id => "budget_form"
    
  end
  
  

def redirect_to_rules_menu
  
end

  def beinformed
    
    @use_jqt = "no"

    @categories = Purchase.payer_top_categories(@payer.id)
    @i = 0
    
    @back_to = "/aol/welcome_signedin"
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
    
    session[:prev_action] = "/aol/purchases_all"
    session[:prev_id] = nil

    
    @purchases = Purchase.full_list(@payer.id)

    @i = 0
    render :action => :purchases
    
  end 
  
  def purchases_by_product
    
    @use_jqt = "no"
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    session[:prev_action] = "/aol/purchases_by_product"
    session[:prev_id] = params[:id]
    
    @purchases = Purchase.by_product_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
    
  end 

  def purchases_by_retailer
    
    @use_jqt = "no"
    
    @back_to = "/aol/beinformed"
    @back_class = "like_back"
    
    session[:prev_action] = "/aol/purchases_by_retailer"
    session[:prev_id] = params[:id]

    
    @purchases = Purchase.by_retailer_id(@payer.id, params[:id])
    @i = 0
    render :action => :purchases
     
  end
  

  def purchases_pending_authorization
    
    @use_jqt = "no"
    
    @back_to = "/aol/welcome_signedin"
    @back_class = "like_back"
    
    session[:prev_action] = "/aol/purchases_pending_authorization"
    session[:prev_id] = nil    
    
    @pending = Purchase.pending_trxs(@payer.id)
    
    if request.post?

      # RAILS BUG MITIGATION - the returned params contain only those purchases that were NOT authorized
      @pending.each do |purchase|
        purchase.update_attributes(:authorization_type => "ManuallyAuthorized")
      end
      Purchase.update(params[:purchase].keys, params[:purchase].values) if params[:purchase]
      

      redirect_to :action => :welcome_signedin 
 
    end
    
  end
  
  def purchases_update
    
    render :action => :welcome_signedin
    
  end
  
  def purchase
    
#    @use_jqt = "no"
    
    if session[:prev_id]                              
      @back_to = session[:prev_action] + '/' +  session[:prev_id]
      @back_class = "like_back"      
    elsif session[:prev_action]      
        @back_to = session[:prev_action]
        @back_class = "like_back"        
    end
 
    begin
      @purchase = Purchase.find(params[:id]) 
    rescue #RecordNotFound
      begin
        @purchase = Purchase.find(params[:id].to_i*10)
      rescue
        flash[:notice] = "Service is temporarily down. Try again in a few moments."
        redirect_to :action => :welcome_signedin
        return       
      end
    end
    session[:purchase] = @purchase

    @consumer = @purchase.consumer || Consumer.find(100)    # This is of course temporary only
    @retailer = @purchase.retailer
    @product = @purchase.product
    @category = @purchase.product.category
    
    @rlist = @retailer.rlist(@payer.id)
    @plist = @product.plist(@payer.id)
    @clist = @category.clist(@payer.id)
    
    session[:retailer_status] = @rlist.status
    session[:product_status] = @plist.status
    session[:category_status] = @clist.status
    
    @authorization = nil
    if @purchase.authorization_type == "PendingPayer"
      @authorization_text = 
            [["Authorize this purchase","ManuallyAuthorized"],
             ["Unauthorize this purchase" , "Unauthorized"]]
    elsif @purchase.authorization_type == "ManuallyAuthorized"
      @purchase.authorization_date ||= Time.now.to_date
      @authorization_text = [" Authorized by you on #{@purchase.authorization_date.strftime("%d/%m/%y")}"]
    elsif @purchase.authorization_type == "Unauthorized" 
      @purchase.authorization_date ||= Time.now.to_date
      @authorization_text = [" Unauthorized by you on #{@purchase.authorization_date.strftime("%d/%m/%y")}"]
    else
      @authorization = "by arca"
    end
    
    
  end
  
  def purchase_update
            
    @purchase = session[:purchase]
 
    if params[:purchase] and 
       params[:purchase][:authorization_type] != @purchase.authorization_type and
       (params[:purchase][:authorization_type] == "ManuallyAuthorized" or params[:purchase][:authorization_type] == "Unauthorized")

       @purchase.authorized = (params[:purchase][:authorization_type] == "ManuallyAuthorized") ?true :false
       @purchase.authorization_type = params[:purchase][:authorization_type]
       @purchase.authorization_date = Time.now 
      
       if Current.policy.online? and Current.policy.send_sms?  
         begin
            inform_consumer_by_sms
         rescue
            flash[:notice] = "We're sorry. service is down"
            redirect_to :action => :welcome_signedin
            raise
            return    
         end
       end
 
    if @purchase.save
#       File.delete("#{RAILS_ROOT}/public/service/purchases/all.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/all.js")
#       File.delete("#{RAILS_ROOT}/public/service/purchases/consumer_#{@purchase.consumer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/consumer_#{@purchase.consumer_id}.js")
#       File.delete("#{RAILS_ROOT}/public/service/purchases/retailer_#{@purchase.retailer_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/retailer_#{@purchase.retailer_id}.js")
#       File.delete("#{RAILS_ROOT}/public/service/purchases/product_#{@purchase.product_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/product_#{@purchase.product_id}.js")
#       File.delete("#{RAILS_ROOT}/public/service/purchases/category_#{@purchase.product.category_id}.js") if File.exist?("#{RAILS_ROOT}/public/service/purchases/category_#{@purchase.product.category_id}.js")
    else
       flash[:notice] = "service is temporarily down"
       redirect_to :action => :welcome_signedin
       return
    end

    end
    
    if params[:rlist][:status] and params[:rlist][:status] != session[:retailer_status]
      @purchase.retailer.update(@payer.id, params[:rlist][:status])
    end 
    if params[:plist][:status] and params[:plist][:status] != session[:product_status]
      @purchase.product.update(@payer.id, params[:plist][:status])
    end 
    if params[:clist][:status] and params[:clist][:status] != session[:category_status]
      @purchase.product.category.update(@payer.id, params[:clist][:status])
    end 
    
    
    if session[:prev_id]
      @back_to = session[:prev_action] + '/' +  session[:prev_id]
    elsif session[:prev_action]
      @back_to = session[:prev_action]
    else
      @back_to = "/aol/welcome_signedin"
    end
    redirect_to @back_to
    
  end
  
  def inform_consumer_by_sms
    
  # Assumptiion: @purchase.expected_pin IS already there (populated by consumer)    

    if @purchase.authorization_type == "ManuallyAuthorized"
      if @purchase.authentication_type == "PIN"
        message = "Congrats! Your purchase of #{@purchase.product.title} has been approved. Use your permanent PIN code!"
      else
        message = "Congrats! Your purchase of #{@purchase.product.title} has been approved. Your PIN: #{@purchase.expected_pin}"
      end
    else
      message = "We're Sorry. Your purchase of #{@purchase.product.title} is not approved."
    end
    
    unless @purchase.consumer_id == 100   # possible only in test mode: pending purchase refers to a consumer once existed and since deleted
      consumer_phone = Consumer.find(@purchase.consumer_id).billing_phone   
      sms(consumer_phone, message)
    end
  
  end
  
  def arca_auth_help
    
    @purchase = session[:purchase]
    
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
          
  
  def sms(phone, message)

    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    api.send_message(phone, message)
    
  end

 
  def help
    
  end
  
  def find_user
    session[:user]||= User.new
  end
   
   def logout
    session[:payer] = session[:pending_count] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
  
  
  protected
  
  def authorize
    

    @payer = session[:payer]
    @user =  session[:user]
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
