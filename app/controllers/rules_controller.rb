class RulesController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_rule  


  # GET /rules
  # GET /rules.json
  def index
    @rules = current_payer.rules
  end

  # GET /rules/1
  # GET /rules/1.json
  def show

  end

  # GET /rules/new
  # GET /rules/new.json
  def new
    @rule = Rule.new(params)
  end

  # GET /rules/1/edit
  def edit

  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.set!(params)
    
    redirect_to purchase_path(
      params[:purchase], 
      :notify => 'rule_setting', 
      :status => 'success', 
      :property => params[:property],
      :value => params[:value],
      :rule_status => params[:status],
      :_pjax => "data-pjax-container"

    )  

  end

  # PUT /rules/1
  # PUT /rules/1.json
  def update
    @rule = Rule.find(params[:id])

    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        format.html { redirect_to @rule, notice: 'Rule was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule = Rule.find(params[:id])
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url }
      format.json { head :ok }
    end
  end

  
  def find_rule  
 
    if params[:id]
      begin    
        @rule = current_payer.rules.find(params[:id])  
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such rule id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
