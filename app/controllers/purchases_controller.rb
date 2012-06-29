class PurchasesController < ApplicationController

  before_filter :check_and_restore_session    
# before_filter :set_long_expiry_headers    # consider moving to application controller

  # GET /consumers/:consumer_id/purchases ("link_to payer_purchases_path(@payer)")
  # GET /payers/:payer_id/purchases       ("link_tp consumer_purchases_path(@consumer)")
  # GET /purchases 

  # shared by both index and show. 
  # Priority: 1. if *only* :id is present - all purchases of that consumer whose purchase is his 
  # Otherwise, 2. all purchases of given consumers, or 3. payer
  def find_purchases
    
    flash[:error] = "id missing" unless params[:payer_id] or params[:consumer_id] or params[:id]

    @purchases = Purchase.with_info(params[:payer_id], params[:consumer_id], params[:id]) 
    @pendings = @purchases.where("authorization_type = 'PendingPayer'")
    @pendings_count = @pendings.count
        
  end
  
  def find_consumer

    unless params[:payer_id]
      @consumer = (params[:consumer_id]) ?Consumer.find(params[:consumer_id]) :Purchase.find(params[:id]).consumer
    end

  end

  def index
    
    find_purchases
    find_consumer
    # purchase is decided by the client
    
    render :partial => 'index' if request.headers['X-PJAX'] # otherwise the full 'index'  
      
  end
  

  # GET /consumers/:consumer_id/purchases/1 ("link_to payer_purchase_path(@consumer, @purchase)")
  # GET /payers/:payer_id/purchases/1       ("link_tp consumer_purchase_path(@payer, @purchase)")
  # GET /purchases/1
  # GET /purchases/1.json
  def show

    find_purchases      # fully RESTfull. pjax frequently brings a full page. Better for caching, enables history.
    find_consumer     
    @purchase = Purchase.find(params[:id])

    if request.headers['X-PJAX']
      render :partial => 'show'
    else
      render 'index'  
    end
    
  end

  def approve
    
    @purchase = Purchase.find(params[:id])
    @purchase.set_rules!(params)
    
    if @purchase.payer.registered?
      @purchase.pay_by_token!
      if @purchase.paid_by_token?
        @purchase.notify_merchant
        @purchase.approve!
        @purchase.account_for! 
        status = 'approved'
      else
        status = 'failed'
      end
      @purchase.notify_consumer('manual', status)
             
    else
      redirect_to @purchase.g2spp('payment')   
      # then the dmn would take care of the notify/approve/inform (make it DRY by having them all in the model)
    end

  end

  def decline
    
    @purchase = Purchase.find(params[:id])
    @purchase.set_rules!(params)
    
    @purchase.decline!
    @purchase.notify_consumer('manual', 'declined')

  end


  def approve1    # callback after G2S PP returned succesfully

    @purchase = Purchase.find(params[:id])
    @purchase.approve!(params)
     
    respond_to do |format|  
      format.js
    end
    
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

end
