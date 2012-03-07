include ActionView::Helpers::NumberHelper
#require 'rubygems'
require 'clickatell'
#require 'paypal_adaptive'
require 'httparty'

class SubscriberController < ApplicationController

#  before_filter :check_friend_authenticated
  before_filter :check_payer_and_set_variables, :except => [:index, :invite, :pay_and_show, :approve, :purchase, :signin, :joinin, :signout, :retailer_signedin]
  before_filter :check_retailer_and_set_variables, :only => [:retailer_signedin]
  

  # for tests only
  def email
      @user = session[:user]
      @consumer = session[:consumer]
      UserMailer.joinin_email(@user, @consumer).deliver
      redirect_to :action => :payer_signedin
  end


  
  def index
    redirect_to :controller => "service", :action => "index"    
  end
  
  def approve
        
    @user = User.find(108)
    if @user
      clear_payer_session if session[:payer] and session[:payer].id  != @user.payer.id 
      session[:user]  = @user
      session[:payer] = @payer = @user.payer
    else
      flash[:notice] = "user or password are incorrect. Please try again!"
    end
    
    redirect_to :action => :payer_signedin, :approve => params[:purchase_id]
    
  end

  def invite
    
    @user = User.authenticate_by_hp(params[:email], params[:authenticity_token])
    if @user
    @user = User.find(108)
      clear_payer_session if session[:payer] and session[:payer].id  != @user.payer.id 
      session[:user]  = @user
      session[:payer] = @payer = @user.payer
    else
      flash[:notice] = "user or password are incorrect. Please try again!"
    end
    
    redirect_to :action => :payer_signedin, :name => params[:name], :invited_by => params[:invited_by]
    
  end
  

  def signin
    
   if request.post?
     
      @user = User.authenticate(params[:user][:email], params[:user][:password])
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
 

  def joinin

    if request.post?
          
      @user = User.new(params[:user])
      @user.affiliation = "payer"
      @user.role = "primary"
      @user.payer = Payer.new() 
     
      set_payer_session
     
      if @user.save
        session[:user] = @user     
        payer = @user.payer
        session[:payer] = payer                  
        redirect_to :action => "payer_signedin"
      else
        if @user.errors.on(:name) == "has already been taken"
            flash.now[:notice] = "User name is taken. Try a differet one!"
        elsif @user.errors.on(:password) == "doesn't match confirmation"
            flash.now[:notice] = "password/confirmation mismatch. Try again!"
        else
            flash.now[:notice] = "something's missing. Please try again!"
        end
      end
      
    end

  end
  

  
  def signout
    
    #session is cleared upon next signin, provided it's not the same user/payer
    redirect_to :controller => :service, :action => :index
    
  end


  def payer_signedin
    
    @consumers = Consumer.find_all_by_payer_id(@payer.id)
#    get_rid_of_duplicates
    session[:consumers] = @consumers 
    # while most are purchase aggregations, @consumer is an actual consumer record
    @consumer = session[:consumer] = (@consumers.empty?) ?nil :Consumer.find(@consumers[0].id)
        
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

#    @max_records = [@consumers.size, @retailers.size, @products.size].max
            
  end
 
  def get_rid_of_duplicates
    
    i = 0
    while i < @consumers.size
    
      consumer = @consumers.at(i)      
      next_one = @consumers.at(i + 1)

      consumer.sum_amount = nil unless consumer.authorized?
      
      if next_one and next_one.id == consumer.id 
        if next_one.authorized?
          consumer.sum_amount = next_one.sum_amount
        end
        @consumers.delete_at(i)
      end
 
      i += 1
 
    end

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
    @registered = session[:payer].registered?
    
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
      if  params[:consumer][:allowance] or params[:consumer][:allowance_period]
            @consumer.balance_on_acd = @consumer.balance
            @consumer.allowance_change_date = Time.now
            @consumer.purchases_since_acd = 0
      end
      if @consumer.update_attributes!(params[:consumer])
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
      format.html { redirect_to :action => 'payer_signedin' }  
      format.js  
    end
    
  end 
   
  
  def purchase
    
    @purchase = session[:purchase] = Purchase.find(params[:id])
    @consumer = @purchase.consumer
    @payer = @purchase.payer
    @approved = (params[:approved] == 'true')
    @activity = session[:activity] = (@approved) ?'approve' :'decline'
    @title = @purchase.product
    @category = @purchase.category.name
    @merchant = @purchase.retailer.name

    if @payer.registered?
      
      @merchant_whitelisted = @purchase.retailer.whitelisted?(@payer.id, @consumer.id)
      @merchant_blacklisted = @purchase.retailer.blacklisted?(@payer.id, @consumer.id)
      @category_whitelisted = @purchase.category.whitelisted?(@payer.id, @consumer.id)
      @category_blacklisted = @purchase.category.blacklisted?(@payer.id, @consumer.id)

      render :layout => 'payer', :action => :registered_form
    else
      render :layout => 'payer', :action => :nonregistered_form
    end
    
  end
  
  def approval_and_rules
    
    @purchase = session[:purchase]
    @activity = session[:activity]
    @status = "ok"

    if params[:approve] == "1"

      if @activity == 'approve' 
        @purchase.manually_authorize!
        #charge payer using SC with stored token (put the code in application_controller so it can be used from consumer)
        #keep return status and confirmation id in new purchase fields
        #update consumer 'balance' (@consumer.record(amount)) if succesful
        #consider putting all above plus inform_consumer in the consumer model, to be used in consumer controller too
        #@status = "ok"  # or not     
      else
        @purchase.manually_decline!
       end      

      inform_consumer(@purchase, @activity) if @status == "ok"
      
    end
    
    if params[:list_merchant]
      if @activity == 'approve'
        @purchase.retailer.whitelist!(@purchase.payer_id, @purchase.consumer_id)
      else
        @purchase.retailer.blacklist!(@purchase.payer_id, @purchase.consumer_id)        
      end
    end
    
    if params[:list_category]
      if @activity == 'approve'
        @purchase.category.whitelist!(@purchase.payer_id, @purchase.consumer_id)
      else
        @purchase.category.blacklist!(@purchase.payer_id, @purchase.consumer_id)        
      end
    end    

    respond_to do |format|  
      format.js    
    end
    
  end
  
  def inform_consumer(purchase, activity)
    
    if activity == 'approve'
      message = "Congrats! Your purchase of #{purchase.product} has been approved."
    elsif activity == 'decline'
      message = "We're Sorry. Your purchase of #{purchase.product} is not approved."
    else
      return
    end
    
    if phone = purchase.consumer.billing_phone
      unless sms(phone, message)
        flash[:notice] = "We're sorry. SMS service is not available at the moment!"
        return    
      end
    end

  end
  
  def pay_and_show
    
    if params[:pay] == "1"

      purchase = session[:purchase]
      merchant_site_id = purchase.retailer.merchant_site_id
      merchant_id = purchase.retailer.merchant_id     
      item = purchase.product
      amount = purchase.amount
      currency = t('currency_code')
      success_url = "http://www.paykido.com/service/registration"      
      error_url = "http://www.paykido.com/service/registration"  

      #temp: to have the checksum match      
      merchant_id = "4678792034088503828" 
      amount = "1"
      item = "test" 
      #temp: to have the checksum match   
     
      pay(merchant_site_id, merchant_id, item, amount, currency, success_url, error_url)
    elsif params[:show] == "1"
      redirect_to "http://www.paykido.com/service/registration"
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
     else
      @consumer = Consumer.find(params[:id])
    end
   
    session[:consumer] = @consumer

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
    session[:consumers] = session[:consumer] =  
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
      flash[:message] = "Congratulations! You have successfully registered to paykido!"
      @payer.update_attributes!(:registered => true)
      redirect_to preapproval_response.preapproval_paypal_payment_url
    else
      puts preapproval_response.errors.first['message']
      flash[:message] = preapproval_response.errors.first['message']
      redirect_to "/subscriber/payer_signedin"
    end
    
  end
  

       
end

