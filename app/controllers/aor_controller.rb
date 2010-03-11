require 'ruby-debug'
#require 'rubygems'
#require 'seer'
class AorController < ApplicationController
  
  before_filter :authorize, :except => [:signin, :welcome_new, :joinin]

  def beinformed

    @categories = Category.all
    @balance = @payer.balance
    @pending = Purchase.pending_amt(@payer.id)

  end


  def rd_to_beinformed
    redirect_to :controller => :aor, :action => :beinformed
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
      redirect_to :controller => 'aor' , :action => :beinformed
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
    redirect_to :controller => 'aor' , :action => :beinformed
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

  protected
    def authorize
    
    @payer = Payer.find_by_id(session[:payer_id])
    unless @payer
      flash[:notice] = "Please log in"
      redirect_to :controller => 'aol' , :action => 'signin'
    end
    
  end

 
  
 end
