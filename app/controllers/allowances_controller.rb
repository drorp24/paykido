class AllowancesController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_allowance  


  # GET /allowances
  # GET /allowances.json
  def index
    @allowances = current_payer.allowances
  end

  # GET /allowances/1
  # GET /allowances/1.json
  def show

  end
  
  # GET /allowances/new
  # GET /allowances/new.json
  def new
    @allowance = allowance.new(params)
  end

  # GET /allowances/1/edit
  def edit

  end

  # POST /allowances
  # POST /allowances.json
  def create

    @allowance = allowance.new(params[:allowance])

    respond_to do |format|
      if @allowance.save
        format.html { redirect_to @allowance, notice: 'allowance was successfully created.' }
        format.json { render json: @allowance, status: :created, location: @allowance }
      else
        format.html { render action: "new" }
        format.json { render json: @allowance.errors, status: :unprocessable_entity }
      end
    end

  end

  # PUT /allowances/1
  # PUT /allowances/1.json
  def update
    @allowance = allowance.find(params[:id])

    respond_to do |format|
      if @allowance.update_attributes(params[:allowance])
        format.html { redirect_to @allowance, notice: 'allowance was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @allowance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allowances/1
  # DELETE /allowances/1.json
  def destroy
    @allowance = allowance.find(params[:id])
    @allowance.destroy

    respond_to do |format|
      format.html { redirect_to allowances_url }
      format.json { head :ok }
    end
  end

  private
  
  def find_allowance  
 
    if params[:consumer_id]
      begin    
        @consumer = Consumer.find(params[:purchase_id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such consumer id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

    if params[:id]
      begin    
        @allowance = (@consumer) ? @consumer.allowances.find(params[:id]) : current_payer.allowances.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such allowance id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
