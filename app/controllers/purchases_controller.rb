class PurchasesController < ApplicationController


  before_filter :check_and_restore_session  # consider moving to application controller
  
#  before_filter :set_long_expiry_headers    # consider moving to application controller

  # GET /consumers/:consumer_id/purchases
  # GET /purchases

  def index

    @purchases = Purchase.with_info(@payer.id, params[:consumer_id])
    if @purchases.any?      
      @purchase = @purchases[0]
      @pendings_count = @purchases.count{|purchase| purchase.authorization_type == 'PendingPayer'}
    else
      @purchase = nil
      @pendings_count = 0      
    end

    render :partial => 'index' if request.xhr?    #otherwise it will render index that contains the full page
      
  end
  
  def approve    # callback after G2S PP returned succesfully

    @purchase = Purchase.find[:id]
    @purchase.approve!(params)
     
    respond_to do |format|  
      format.js
    end
    
  end
  


  # GET /purchases/1
  # GET /purchases/1.json
  def show

    @purchases = Purchase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase }
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

  private
  
  def check_and_restore_session  
 
    unless session[:payer]            # replace with Devise  
      flash[:message] = "Please sign in with payer credentials"
      reset_session
      redirect_to  :controller => 'home', :action => 'index'
      return
    end
        
    @payer = session[:payer] 

  end
  
  def set_long_expiry_headers
    response.headers["Expires"] = CGI.rfc1123_date(Time.now + 1.year)   
  end
               
end
