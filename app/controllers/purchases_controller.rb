class PurchasesController < ApplicationController

  before_filter :check_and_restore_session  

  # GET /consumers/:consumer_id/purchases ("link_to payer_purchases_path(@payer)")
  # GET /payers/:payer_id/purchases       ("link_tp consumer_purchases_path(@consumer)")
  # GET /purchases 

  # shared by both index and show. 
  # Priority: 1. if *only* :id is present - all purchases of that consumer whose purchase is his 
  # Otherwise, 2. all purchases of given consumers, or 3. payer
  def find_purchases
    
    @purchases = Purchase.with_info(params[:payer_id], params[:consumer_id], params[:id]) 
    @pendings = @purchases.pending
    @pendings_count = @pendings.count
        
  end
  
  def index
    
    find_purchases
    @purchase.notify_merchant('approved') if params[:Status] and params[:Status] == 'APPROVED'
      
  end
  

  # GET /consumers/:consumer_id/purchases/1 ("link_to payer_purchase_path(@consumer, @purchase)")
  # GET /payers/:payer_id/purchases/1       ("link_tp consumer_purchase_path(@payer, @purchase)")
  # GET /purchases/1
  # GET /purchases/1.json
  def show

    find_purchases      # fully RESTfull. pjax frequently brings a full page. Better for caching, enables history.
    begin    
      @purchase = Purchase.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such purchase exists"
      redirect_to (params[:consumer_id]) ?consumer_purchases_path(params[:consumer_id]) :payer_purchases_path(params[:payer_id])
      return
    end

    if request.headers['X-PJAX']
      render :partial => 'show'
    else
      render 'index'  
    end
    
  end

  def approve
    
    unless @purchase.payer.registered?
      redirect_to @purchase.g2spp   
      # then the dmn would take care of the notify/approve/inform (make it DRY by having them all in the model)
      return            
    end

    @purchase.set_rules!(params)

    @purchase.pay_by_token!
    if @purchase.paid_by_token?
      status = 'approved'
      @purchase.notify_merchant(status)
      @purchase.approve!
      @purchase.account_for! 
    else
      status = 'failed'
    end

    @purchase.notify_consumer('manual', status)

    respond_to do |format|  
      format.js
    end

  end

  def decline
    
    @purchase = Purchase.find(params[:id])
    @purchase.set_rules!(params)
    
    @purchase.decline!
    @purchase.notify_consumer('manual', 'declined')

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

  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    super
    if flash[:error]
      redirect_to login_path 
      return
    end
        
    if params[:id]
      begin    
        @purchase = Purchase.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end


end
