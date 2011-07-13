include ActionView::Helpers::NumberHelper
require 'rubygems'
require 'clickatell'
require 'paypal_adaptive'


class SubscriberController < ApplicationController

  before_filter :check_friend_authenticated
  before_filter :check_payer_and_set_variables, :except => [:index, :signin, :joinin, :signout, :retailer_signedin]
  before_filter :check_retailer_and_set_variables, :only => [:retailer_signedin]
  
  
  def index
    
  end
  
  
  def signin
    
   if request.post?
     
      @user = User.authenticate(params[:user][:name], params[:user][:password])
      unless @user
        flash.now[:notice] = "user or password are incorrect. Please try again!"
        return
      end

      if @user.is_payer
        set_payer_session
        redirect_to :action => :payer_signedin
      elsif @user.is_retailer
        set_retailer_session
        redirect_to :action => :retailer_signedin
      elsif @user.is_administrator
        redirect_to :action => :administrator_signedin
      elsif @user.is_friend
        flash.now[:notice] = "Please use a valid payer user, not the Beta invitation user"      
      else
        flash.now[:notice] = "Please use a valid payer user"      
     end
      
   end
   
  end
 

  def signout
    
    #session is cleared upon next signin, provided it's not the same user/payer
    redirect_to :action => :index
    
  end


  def payer_signedin
    
    # while most are purchase aggregations, @consumer is an actual consumer record
    @consumers = Purchase.payer_consumers_the_works(@payer.id)
    session[:consumers] = @consumers 
    session[:consumer] = (@consumers.empty?) ?nil :Consumer.find(@consumers[0].id)
        
    @retailers = Purchase.payer_retailers_the_works(@payer.id)
    session[:retailers] = @retailers
    session[:retailer] = (@retailers.empty?) ?nil :@retailers[0]
    
    @products = Purchase.payer_products_the_works(@payer.id)
    session[:products] = @products
    session[:product] = (@products.empty?) ?nil :@products[0]
    
    @categories = Purchase.payer_categories_the_works(@payer.id)
    session[:categories] = @categories
    session[:category] = (@categories.empty?) ?nil :@categories[0]
        
    @purchases = Purchase.payer_purchases_the_works(@payer.id)      
    session[:purchases] = @purchases

    @max_records = [@consumers.size, @retailers.size, @products.size].max
            
  end
 
  def consumers
    
    @consumers = session[:consumers]
    
    respond_to do |format|  
      format.js  
    end
    
  end
  
  def retailers

    @retailers = session[:retailers]
    
    respond_to do |format|  
      format.js  
    end
    
  end

  def products
    
    @products = session[:products]
    
    respond_to do |format|  
      format.js  
    end
    
  end
  
  def categories
    
    @categories = session[:categories]
    
    respond_to do |format|  
      format.js  
    end
    
  end
  
  def purchases
    
    @purchases = session[:purchases]
    
    respond_to do |format|  
      format.js
    end
    
  end
        
  def consumer

    find_consumer

    respond_to do |format|  
      format.js  
    end

  end
 
  def retailer
    
    find_retailer
      
    respond_to do |format|  
      format.js  
    end
    
  end
  
  def product
    
    find_product
      
    respond_to do |format|  
      format.js  
    end
    
  end

  def category
    
    find_category
      
    respond_to do |format|  
      format.js  
    end
    
  end


  def consumer_update
    
    find_consumer

    if params[:consumer] 
      if @consumer.update_attributes(params[:consumer])
        session[:consumer] = @consumer
      else
        flash[:notice] = "Invalid... please try again!"
        return
      end
    end
    
    if params[:payer_rule] 
      if @consumer_rule.update_attributes(params[:payer_rule]) 
        session[:consumer_rule] = @consumer_rule
      else
        flash[:notice] = "Invalid... please try again!"
        return
      end
    end
 
    if params[:name] 
      if @consumer.update_attributes(:name => params[:name])
        session[:consumer] = @consumer
      else
        flash[:notice] = "Invalid... please try again!"
        return
      end
    end

    
    respond_to do |format|  
      format.js  
    end
    
  end
  

  def payer_update
    
    if params[:payer]      
      if @payer.update_attributes(params[:payer])
        session[:payer] = @payer
      else
        flash[:notice] = "Invalid... please try again!"
      end
    end
    
    if params[:name] 
      if @payer.update_attributes(:name => params[:name])
        session[:payer] = @payer
      else
        flash[:notice] = "Invalid... please try again!"
        return
      end
    end

    respond_to do |format|  
      format.js  
    end
    
  end 
  
  
  def rlist_update    

   @rlist = Rlist.find_or_initialize_by_payer_id_and_retailer_id(@payer.id, params[:id])
    unless @rlist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Server unavailble. Back in a few moments!"
    end
   
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end
    
    
  end

  def plist_update
    
   @plist = Plist.find_or_initialize_by_payer_id_and_product_id(@payer.id, params[:id])
    unless @plist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Server unavailble. Back in a few moments!"
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end    
    
  end
  
  def clist_update
    
   @clist = Clist.find_or_initialize_by_payer_id_and_category_id(@payer.id, params[:id])
    unless @clist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Server unavailble. Back in a few moments!"
    end
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end    
    
  end
  
  def purchase_update
    
    @purchase = Purchase.find(params[:id])

    if params[:new_status] and 
       params[:new_status] != @purchase.authorization_type 

       @purchase.authorized = (params[:new_status] == "ManuallyAuthorized") ?true :false
       @purchase.authorization_type = params[:new_status]
       @purchase.authorization_date = Time.now 
      
       unless @purchase.save
        flash[:notice] = "service is temporarily down. Please hold for a few moments"
        return
       end

       if Current.policy.send_sms? 
          inform_consumer_by_sms
          if @sms_failed
            flash[:notice] = "We're sorry. SMS service is down at the moment!"
            return    
          end
       end
     
       respond_to do |format|  
         format.js  
       end    
      
    end
    
  end
    
  def inform_consumer_by_sms
        
    if @purchase.authorization_type == "ManuallyAuthorized"
      message = "Congrats! Your purchase of #{@purchase.product.title} has been approved."
     else
      message = "We're Sorry. Your purchase of #{@purchase.product.title} is not approved."
    end
    
    if phone = @consumer.billing_phone
      sms(phone, message)
      return if @sms_failed
    end          
 
  end   

  
  def sms(phone, message)
    
    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    begin
      api.send_message(phone, message)
    rescue 
      @sms = "failed"
    end
    
  end
   
  
  
  
  def retailer_signedin
     
    @sales = Purchase.retailer_sales(@retailer.id)
        
    @categories = Purchase.retailer_top_categories(@retailer.id)
    @i = 0
     
  end
  


  protected
  
  def set_payer_session
    
   clear_payer_session if session[:payer] and session[:payer].id  != @user.payer.id 
 
   session[:user]  = @user
   session[:payer] = @payer = @user.payer

 end
  
  def check_payer_and_set_variables
    
   check_payer_is_signedin
   refresh_payer_variables_from_session
    
  end

  def check_payer_is_signedin
    
    unless session[:payer]  
      flash[:message] = "Please sign in with payer credentials"
      clear_payer_session
      redirect_to  :action => 'index'
    end   
    
  end
  
  def check_friend_authenticated    
    session[:req_controller] = params[:controller]
    session[:req_action] = params[:action]
    redirect_to  :controller => 'welcome', :action => 'index' unless session[:friend_authenticated]    
  end


  
  def set_retailer_session
    
   clear_retailer_session if session[:retailer] and session[:retailer].id  != @user.retailer.id 

   session[:user]     = @user
   session[:retailer] = @retailer = @user.retailer

 end
  
  def check_retailer_and_set_variables
    
   refresh_retailer_variables_from_session
    
  end
  
  def check_retailer_is_signedin
    
    unless session[:retailer]
      flash[:message] = "Please sign in with retailer credentials"
      clear_retailer_session
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
  
  
  def find_consumer
    
    if session[:consumer] and session[:consumer].id == params[:id]
      @consumer = session[:consumer]
      @consumer_rule = session[:consumer_rule]
    else
      @consumer_purchases = session[:consumers].select{|consumer| consumer.id == params[:id].to_i}[0]
      @consumer = Consumer.find(@consumer_purchases.id)
      @consumer_rule = @consumer.most_recent_payer_rule
    end
   
    session[:consumer] = @consumer
    session[:consumer_rule] = @consumer_rule
    
  end
  
  
  def find_retailer

    if session[:retailer] and session[:retailer].id == params[:id]
      @retailer = session[:retailer]
    else
      @retailer = session[:retailers].select{|retailer| retailer.id == params[:id].to_i}[0]
    end

    session[:retailer] = @retailer
    
  end

  def find_product

    if session[:product] and session[:product].id == params[:id]
      @product = session[:product]
    else
      @product = session[:products].select{|product| product.id == params[:id].to_i}[0]
    end

    session[:product] = @product
    
  end

  def find_category

    if session[:category] and session[:category].id == params[:id]
      @category = session[:category]
    else
      @category = session[:categories].select{|category| category.id == params[:id].to_i}[0]
    end

    session[:category] = @category
    
  end


  def refresh_payer_variables_from_session
    
    @user =       session[:user]
    @payer =      session[:payer]

  end

  def refresh_retailer_variables_from_session
    
    @user =       session[:user]
    @retailer =      session[:retailer]

  end

  
  def clear_payer_session
    session[:user] = session[:payer] =
    session[:consumers] = session[:consumer] =  session[:consumer_rule] = 
    session[:retailers] = session[:retailer] = 
    session[:products] = session[:product] =
    session[:categories] = session[:category] =
    session[:purchases] = session[:purchase] =
    nil
  end
  
  def clear_retailer_session
    session[:user] = session[:retailer] = session[:same_as_last_retailer] = nil    
  end
  
  
  def preapproval
    
    preapproval_request = PaypalAdaptive::Request.new
  
    data = {
    "returnUrl" => "http://#{request.host}/subscriber/payer_signedin",
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=>"USD",
    "cancelUrl"=>"http://#{request.host}/subscriber/payer_signedin",
    "maxTotalAmountOfAllPayments" => "1500.00",
    "maxNumberOfPayments" => "30",
    "startingDate" => DateTime.now.to_s,
    "endingDate" => (DateTime.now + 365).to_s,
    "senderEmail" => "drorp1_1297098617_per@yahoo.com"
    }
      
    preapproval_response = preapproval_request.preapproval(data)
      
    session[:preapprovalKey] = preapproval_response['preapprovalKey']
      
    if preapproval_response.success?
      flash[:message] = "Congratulations! You have successfully registered to Arca!"
      @payer.update_attributes!(:registered => true)
      redirect_to preapproval_response.preapproval_paypal_payment_url
    else
      puts preapproval_response.errors.first['message']
      flash[:message] = preapproval_response.errors.first['message']
      redirect_to "/subscriber/payer_signedin"
    end
    
  end
  

       
end

