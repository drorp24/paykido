class BillingsController < ApplicationController
  # GET /billings
  # GET /billings.xml
  def index
    @billings = Billing.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @billings }
    end
  end

  # GET /billings/1
  # GET /billings/1.xml
  def show
    @billing = Billing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @billing }
    end
  end

  # GET /billings/new
  # GET /billings/new.xml
  def new
    @billing = Billing.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @billing }
    end
  end

  # GET /billings/1/edit
  def edit
    @billing = Billing.find(params[:id])
  end

  # POST /billings
  # POST /billings.xml
  def create
    @billing = Billing.new(params[:billing])

    respond_to do |format|
      if @billing.save
        flash[:notice] = 'Billing was successfully created.'
        format.html { redirect_to(@billing) }
        format.xml  { render :xml => @billing, :status => :created, :location => @billing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @billing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /billings/1
  # PUT /billings/1.xml
  def update
    @billing = Billing.find(params[:id])

    respond_to do |format|
      if @billing.update_attributes(params[:billing])
        flash[:notice] = 'Billing was successfully updated.'
        format.html { redirect_to(@billing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @billing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /billings/1
  # DELETE /billings/1.xml
  def destroy
    @billing = Billing.find(params[:id])
    @billing.destroy

    respond_to do |format|
      format.html { redirect_to(billings_url) }
      format.xml  { head :ok }
    end
  end
end
