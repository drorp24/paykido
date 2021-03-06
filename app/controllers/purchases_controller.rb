class PurchasesController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_purchase
  
  # shared by both index and show. 
  # Priority: 1. if *only* :id is present - all purchases of that consumer whose purchase is his 
  # Otherwise, 2. all purchases of given consumers, or 3. payer
  def find_purchases
    
    if params[:id] 
      purchase = Purchase.find_by_id(params[:id])
      @consumer_id = purchase.consumer_id if purchase
    elsif params[:consumer_id] 
      @consumer_id = params[:consumer_id]
    else
      @consumer_id = nil
    end

    @purchases = Purchase.with_info(current_payer.id, @consumer_id) 
    @pendings = @purchases.pending 
    @pendings_count = @pendings.count
        
  end
  
  def index    
    find_purchases
    unless @purchases.any?
      if current_payer.purchases.any?
        redirect_to purchases_path(:notify => 'no_purchases', :consumer_number => @consumer_id)
      elsif current_payer.registered?
        redirect_to tokens_path(:notify => 'no_purchases', :consumer_number => @consumer_id, :_pjax => "data-pjax-container")
      else  
        redirect_to new_token_path(:notify => 'no_purchases', :consumer_number => @consumer_id, :_pjax => "data-pjax-container")
      end
    end
  end
  


  # since the entire page includes all payer's purchases too, it's better that 'show' brings them too.
  # it enables caching the entire page and enables pjax history. Besides, pjax sometimes brings an entire page.
  # the payer's purchases is a cached DB query, and once a certain purchase is brought the entire page is cached at the web server level
  
  def show
    if request.headers['X-PJAX'] and params[:_pjax] != 'data-pjax-container'   # (ugly) the latter implies the whole page is requested
      render :partial => 'show'
    else
      find_purchases
      render :index, :id => params[:id]
    end

  end

  def approve
    
    if @purchase.requires_manual_payment?
      redirect_to @purchase.g2spp         
      # then g2s#ppp_callback informs the status and g2s#dmn creates the trx, notifies the consumer and the merchant 
      return            
    end

    @purchase.pay_by_token!(request.remote_ip)
    if @purchase.paid_by_token?
      status = 'approved'
      @purchase.approve!
    else
      status = 'failed'
    end

    unless status == 'failed'
      notification_status = @purchase.notify_merchant(status, 'approval')
      if notification_status == "OK"
        @purchase.account_for! if status == 'approved'
      else
        @purchase.notification_failed!
        status = 'failed'
      end
    end

    Sms.notify_consumer(@purchase.consumer, 'approval', status, @purchase, 'manual')   

    redirect_to purchase_path(
      @purchase,
      :notify => 'approval', 
      :status => status,
      :purchase => @purchase.id,
      :notification_status => notification_status,
      :_pjax => "data-pjax-container"
    )  

  end
  
  def decline
    
    @purchase.decline!
    notification_status = @purchase.notify_merchant('declined', 'denial')
    if notification_status == "OK"
      status = 'success'
    else
      @purchase.notification_failed!
      status = 'failed'
    end
    Sms.notify_consumer(@purchase.consumer, 'approval', 'declined', @purchase, 'manual')

    redirect_to purchase_path(
      @purchase,
      :notify => 'denial', 
      :status => status,
      :purchase => @purchase.id, 
      :_pjax => "data-pjax-container"
    )  

  end


  # GET /purchases/new
  # GET /purchases/new.json
  def new
    @purchase = Purchase.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @purchase }
    end
  end

  # GET /purchases/1/edit
  def edit
    @purchase = Purchase.find(params[:id])
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = Purchase.new(params[:purchase])

    respond_to do |format|
      if @purchase.save
        format.html { redirect_to @purchase, notice: 'Purchase was successfully created.' }
        format.json { render json: @purchase, status: :created, location: @purchase }
      else
        format.html { render action: "new" }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /purchases/1
  # PUT /purchases/1.json
  def update
    @purchase = Purchase.find(params[:id])

    respond_to do |format|
      if @purchase.update_attributes(params[:purchase])
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase = Purchase.find(params[:id])
    @purchase.destroy

    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :ok }
    end
  end

  private  

  def find_purchase  
 
    if params[:id]
      begin    
        @purchase = current_payer.purchases.find(params[:id])   
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

    if params[:purchase]
      begin    
        @purchase = current_payer.purchases.find(params[:purchase])   
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end
    
    @consumer ||= @purchase ? @purchase.consumer : Consumer.find_by_id(params[:consumer_id])           

  end


end
