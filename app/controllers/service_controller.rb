include ActionView::Helpers::NumberHelper
require 'rubygems'
require 'clickatell'

class ServiceController < ApplicationController

  before_filter :check_payer_and_set_variables, :except => [:index, :signin, :joinin, :signout]
  
  caches_page :consumers
  caches_page :retailers
  caches_page :products
  caches_page :categories
  caches_page :pendings
  caches_page :consumer
  caches_page :retailer
  caches_page :product
  caches_page :category
  caches_page :pending
  caches_page :purchase

  def joinin

    if request.post?
      
      @user = User.new(params[:user])
      @user.affiliation = "payer"
      @user.role = "primary"
      @user.payer = Payer.new(:exists => true) 
     
      if @user.save
        session[:user] = @user     
        payer = @user.payer
        session[:payer] = payer                  
        payer_rule = payer.payer_rules.create!(:allowance => 0, :rollover => false, :auto_authorize_under => 10, :auto_deny_over => 25)
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
        set_payer_session_and_cache
        redirect_to :action => :payer_signedin
      elsif @user.is_retailer
        set_retailer_session_and_cache
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
    
    #session and cache will be cleared only upon next sign in (and provided it's not to the same user/payer)
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

  def products
    
    @products = session[:products]
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def categories
    
    @categories = session[:categories]
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
   def pendings
    
    @pendings = session[:pendings]
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
    def purchases
    
    @purchases = select_purchases(session[:purchases], params[:id], params[:ent], params[:period])
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def purchases_all
    
    @purchases = Purchase.payer_purchases_all_the_works(@payer.id)

    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.json { render :layout => false ,
                    :json => @purchases.to_json }
      format.js
    end
    
    
  end
  
  def select_purchases(purchases, id, ent, period)
    
   
    if period == "Pending"
      purchases.select{|purchase| purchase.authorization_type == "PendingPayer"}
    elsif period == "Last week"
      curr_week = Time.now.strftime("%W")
      purchases.select{|purchase| purchase.date.to_date > 1.week.ago.to_date}
    elsif period == "Last month"
      curr_month = Time.now.strftime("%m")
      purchases.select{|purchase| purchase.date.to_date > 1.month.ago.to_date}
    else
      purchases
    end
    
  end

  def payer_signedin
    
#    unless session[:same_as_last_payer]       # doesnt help a bit
      
        @consumers = Consumer.payer_consumers_the_works(@payer.id)
        get_rid_of_duplicates
        session[:consumers] = @consumers 
        session[:consumer] = (@consumers.empty?) ?nil :@consumers[0]
        flash[:message] = "Welcome to arca!" if @consumers.empty?
        
        @retailers = Purchase.payer_retailers_the_works(@payer.id)
        sort_retailers
        session[:retailers] = @retailers
        session[:retailer] = (@retailers.empty?) ?nil :@retailers[0]
    
        @products = Purchase.payer_products_the_works(@payer.id)
        sort_products
        session[:products] = @products
        session[:product] = (@products.empty?) ?nil :@products[0]
    
        @categories = Purchase.payer_categories_the_works(@payer.id)
        sort_categories
        session[:categories] = @categories
        session[:category] = (@categories.empty?) ?nil :@categories[0]
        
        @pendings = Purchase.payer_pendings_the_works(@payer.id)
    #    sort_pendings
        session[:pendings] = @pendings
        session[:pending] = (@pendings.empty?) ?nil :@pendings[0]
    
        @purchases = Purchase.payer_purchases_the_works(@payer.id)
    #    sort_purchases
        session[:purchases] = @purchases
        session[:purchase] = (@purchases.empty?) ?nil :@purchases[0]
        
        @purchases = Purchase.payer_purchases_all_the_works(@payer.id)


#    end

    @consumers_size = session[:consumers].size
    @purchases_size = session[:purchases].size
    @retailers_size = session[:retailers].size
    
  end
 
  def get_rid_of_duplicates
    
    to_delete = []
    i = 0
    while i < @consumers.size
    
      consumer = @consumers.at(i)      
      next_one = @consumers.at(i + 1)
      next_two = @consumers.at(i + 2)
   
      consumer.sum_amount = nil unless consumer.authorized?
      
      if next_one and next_one.id == consumer.id 
        if next_one.authorized?
          consumer.sum_amount = next_one.sum_amount
        end
        @consumers.delete_at(i)
        if next_two and next_two.id == consumer.id 
          if next_two.authorized?
            consumer.sum_amount = next_two.sum_amount
          end
          @consumers.delete_at(i)
         end        
      end
      i += 1
 
    end

end

  def sort_retailers
    
    @retailers.sort! {|x,y| y.total_amount.to_i <=> x.total_amount.to_i }
    
  end
  
  def sort_products
    
    @products.sort! {|x,y| y.total_amount.to_i <=> x.total_amount.to_i }
    
  end
  
  def sort_categories
    
    @categories.sort! {|x,y| y.total_amount.to_i <=> x.total_amount.to_i }
    
  end

  def sort_pendings
    
    @pendings.sort! {|x,y| y.date <=> x.date }
    
  end
  def sort_purchases
    
    @purchases.sort! {|x,y| y.date <=> x.date }
    
  end
  
  def consumer

    find_consumer

    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end

  end
 
  def retailer
    
    find_retailer
    expires_in 1.year
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def product
    
    find_product
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end

  def category
    
    find_category
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end

  def pending
    
    find_pending
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end

  def purchase
    
    find_purchase
      
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end

  def rename_consumer
    
    find_consumer
    @consumer.update_attributes!(:name => params[:name])
    expire_page :action => "consumer", :id => @consumer.id
    expire_page :action => "consumers", :id => 0
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def consumer_rules_update
    
    find_consumer 
    @consumer.update_attributes!(params[:consumer]) if params[:consumer] and @consumer.balance != params[:consumer][:balance]
    @payer_rule.update_attributes!(params[:payer_rule]) 
    expire_page :action => "consumer", :id => @consumer.id
    expire_page :action => "consumers", :id => 0
    
    respond_to do |format|  
      format.html { redirect_to :action => 'JP' }  
      format.js  
    end
    
  end
  
  def payment_update
    
    unless @payer.update_attributes(params[:payer])
      flash[:notice] = "Invalid... please try again!"
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
    session[:retailer].status = params[:new_status]
    expire_page :action => "retailer", :id => params[:id]
   
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end
    
    
  end

   def plist_update
    
   @plist = Plist.find_or_initialize_by_payer_id_and_product_id(@payer.id, params[:id])
    unless @plist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Oops... server unavailble. Back in a few moments!"
    end
    session[:product].status = params[:new_status]
    expire_page :action => "product", :id => params[:id]
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end    
    
  end
  
   def clist_update
    
   @clist = Clist.find_or_initialize_by_payer_id_and_category_id(@payer.id, params[:id])
    unless @clist.update_attributes(:status => params[:new_status])
      flash[:notice] = "Oops... server unavailble. Back in a few moments!"
    end
    session[:category].status = params[:new_status]
    expire_page :action => "category", :id => params[:id]
    
    respond_to do |format|  
      format.html { redirect_to :action => 'index' }  
      format.js  
    end    
    
  end
  
  def purchase_update
    
   @purchase = Purchase.find(params[:id])
    unless @purchase.update_attributes(:authorization_type => params[:new_status])
      flash[:notice] = "Oops... server unavailble. Back in a few moments!"
    end
    session[:pending].authorization_type = params[:new_status]
    expire_page :action => "pending", :id => params[:id]
    expire_page :action => "pendings"
    
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

      session[:expected_pin] = rand.to_s.last(4)
 
      begin
        sms(@consumer.billing_phone,"Welcome to arca. Your PIN code is: #{session[:expected_pin]}")
      rescue Clickatell::API::Error
        flash[:notice] = "Can't locate phone. Please check the number"
      else
        find_payer_rule
        @consumer.balance = @payer_rule.allowance
        session[:phone_is_ok] = true
        session[:consumer] = @consumer
        flash[:notice] = "Thank you. A text message with the PIN code is on its way!"        
      end

      respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
      end 
 
    end
    
    
  end
        
  
  def sms(phone, message)

    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    api.send_message(phone, message)
    
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
        @consumer.update_attributes!(:payer_id => @payer.id, :balance => @def_payer_rule.allowance)
        @phone = @consumer.billing_phone
        session[:consumer] = @consumer
        session[:payer_rule] = @consumer.payer_rules.create!(:allowance => @def_payer_rule.allowance, :rollover => @def_payer_rule.rollover, :auto_authorize_under => @def_payer_rule.auto_authorize_under, :auto_deny_over => @def_payer_rule.auto_deny_over)
        flash[:message] = "Thank you. #{number_to_phone(@phone, :area_code => true)} is now assigned to you!"
        expire_page :action => "consumers", :id => 0
 
        respond_to do |format|  
          format.html { redirect_to :action => 'payer_signedin' }  
          format.js  
        end
    end

  end


  protected
  
  def set_payer_session_and_cache
    
   if session[:payer] and session[:payer].id  == @user.payer.id 
     session[:same_as_last_payer] = true
   else
      session[:same_as_last_payer] = false
      clear_cache
      clear_session
   end 
   session[:payer] = @user.payer
   session[:user]  = @user

 end
  
  def check_payer_and_set_variables
    
   check_payer_is_signedin
   refresh_variables_from_session
    
  end

  def check_payer_is_signedin
    
    unless session[:payer]  # check that payer is signed in
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
      @consumer = session[:consumers].select{|consumer| consumer.id == params[:id].to_i}[0]
      @payer_rule = @consumer.most_recent_payer_rule
    else      # params[:id] == 999 (indicating a blank consumer)
      @consumer = init_consumer
      @payer_rule = init_payer_rule
    end
   
    session[:consumer] = @consumer
    session[:payer_rule] = @payer_rule
    
  end
  
  
  def find_retailer

    if session[:retailer] and session[:retailer].id == params[:id]
      @retailer = session[:retailer]
    elsif params[:id] and params[:id] != "0"
      @retailer = session[:retailers].select{|retailer| retailer.id == params[:id].to_i}[0]
    end

    session[:retailer] = @retailer
    
  end

  def find_product

    if session[:product] and session[:product].id == params[:id]
      @product = session[:product]
    elsif params[:id] and params[:id] != "0"
      @product = session[:products].select{|product| product.id == params[:id].to_i}[0]
    end

    session[:product] = @product
    
  end

  def find_category

    if session[:category] and session[:category].id == params[:id]
      @category = session[:category]
    elsif params[:id] and params[:id] != "0"
      @category = session[:categories].select{|category| category.id == params[:id].to_i}[0]
    end

    session[:category] = @category
    
  end

  def find_pending

    if session[:pending] and session[:pending].id == params[:id]
      @pending = session[:pending]
    elsif params[:id] and params[:id] != "0"
      @pending = session[:pendings].select{|purchase| purchase.id == params[:id].to_i}[0]
    end

    session[:pending] = @pending
    
  end

  def find_purchase

    if session[:purchase] and session[:purchase].id == params[:id]
      @purchase = session[:purchase]
    elsif params[:id] and params[:id] != "0"
      @purchase = session[:purchases].select{|purchase| purchase.id == params[:id].to_i}[0]
    end

    session[:purchase] = @purchase
    
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
 
  def find_payer_rule
    
    if session[:payer_rule]
      @payer_rule = session[:payer_rule]
    else
      @payer_rule = find_def_payer_rule
    end
    
  end
  
  def refresh_variables_from_session
    
# @payer is needed by MANY activities so it belongs here. Not sure about user and payer_rule   
    @user =       session[:user]
    @payer =      session[:payer]
    @consumer =   session[:consumer]
    @payer_rule = find_payer_rule
# Do I need the following for EVERY activity? I don't think so
#    @consumers =  session[:consumers]

#    @retailers =  session[:retailers]
#    @retailer =   session[:retailer]
#    @products =  session[:products]
#    @product =   session[:product]
#    @categories = session[:categories]
#    @category = session[:category]
#    @pendings = session[:pendings]
#    @pending = session[:pending]
#    @purchases = session[:purchases]
#    @purchase = session[:purchase]

  end


  def clear_cache
    
    expire_page :action => "consumers", :id => 0
    expire_page :action => "retailers"
    expire_page :action => "products"
    expire_page :action => "categories"
    expire_page :action => "pendings"
    expire_page :action => "purchases"
    session[:consumers].each{|consumer| expire_page :action => :consumer, :id => consumer.id}  if session[:consumers]
    session[:retailers].each{|retailer| expire_page :action => :retailer, :id => retailer.id}  if session[:retailers]
    session[:products].each{|product| expire_page :action => :product, :id => product.id}      if session[:products]
    session[:categories].each{|category| expire_page :action => :category, :id => category.id} if session[:categories]
    session[:pendings].each{|purchase| expire_page :action => :pending, :id => purchase.id}    if session[:pendings]
    session[:purchases].each{|purchase| expire_page :action => :pending, :id => purchase.id}   if session[:purchases]
   
  end
  
  def clear_session
    session[:user] = session[:payer] = session[:payer_rule] = session[:expected_pin] = session[:same_as_last_payer] =
    session[:consumers] = session[:consumer] = 
    session[:retailers] = session[:retailer] = 
    session[:products] = session[:product] =
    session[:categories] = session[:category] =
    session[:pendings] = session[:pending] =
    session[:purchases] = session[:purchase] =
    nil
  end
  
end
