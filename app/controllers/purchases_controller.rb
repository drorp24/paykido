class PurchasesController < ApplicationController

  before_filter :check_and_restore_session    
# before_filter :set_long_expiry_headers    # consider moving to application controller

  # GET /consumers/:consumer_id/purchases
  # GET /purchases

  def index

    @purchases = Purchase.with_info(@payer.id, params[:consumer_id])
    @pendings = @purchases.where("authorization_type = 'PendingPayer'")
    @pendings_count = @pendings.count
    @purchase = (@pendings_count > 0) ? @pendings.last : @purchases.last
    
    render :partial => 'index' if request.headers['X-PJAX']    #otherwise it will render index that contains the full page
      
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

  # GET /purchases/1
  # GET /purchases/1.json
  def show

    @purchase = Purchase.find(params[:id])

    render :partial => 'show'
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
