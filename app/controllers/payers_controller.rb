class PayersController < ApplicationController
  # GET /payers
  # GET /payers.xml
  def index
    @payers = Payer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payers }
    end
  end

  # GET /payers/1
  # GET /payers/1.xml
  def show
    @payer = Payer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payer }
    end
  end

  # GET /payers/new
  # GET /payers/new.xml
  def new
    @payer = Payer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payer }
    end
  end

  # GET /payers/1/edit
  def edit
    @payer = Payer.find(params[:id])
  end

  # POST /payers
  # POST /payers.xml
  def create
    @payer = Payer.new(params[:payer])

    respond_to do |format|
      if @payer.save
        flash[:notice] = 'Payer was successfully created.'
        format.html { redirect_to(@payer) }
        format.xml  { render :xml => @payer, :status => :created, :location => @payer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payers/1
  # PUT /payers/1.xml
  def update
    @payer = Payer.find(params[:id])

    respond_to do |format|
      if @payer.update_attributes(params[:payer])
        flash[:notice] = 'Payer was successfully updated.'
        format.html { redirect_to(@payer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payers/1
  # DELETE /payers/1.xml
  def destroy
    @payer = Payer.find(params[:id])
    @payer.destroy

    respond_to do |format|
      format.html { redirect_to(payers_url) }
      format.xml  { head :ok }
    end
  end
end
