class RulesController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_rule  


  # GET /rules
  # GET /rules.json
  def index
    @rules = (@consumer) ? @consumer.rules : current_payer.rules
  end

  # GET /rules/1
  # GET /rules/1.json
  def show

  end
  
  # GET /rules/new
  # GET /rules/new.json
  def new
     if params[:property] == '_allowance' and params[:consumer_id] and last_allowance_rule = @consumer.allowance_rule 
      @rule = Rule.new_allowance_rule(last_allowance_rule)
    else
      @rule = Rule.new
    end
  end

  # GET /rules/1/edit
  def edit

  end

  # POST /rules
  # POST /rules.json
  def create

    if params[:purchase_id]         #Todo: temp: handle all rules the same way. 
      @rule = Rule.set!(params)
    else
     @rule = Rule.create_new!(params[:rule])
    end
    
    if params[:purchase_id]
      redirect_to purchase_path(
        params[:purchase_id], 
        :notify => 'rule_setting', 
        :status => 'success', 
        :property => params[:property],
        :value => params[:value],
        :rule_status => params[:rule_status]) 
    else 
      redirect_to consumer_rules_path(
        params[:rule][:consumer_id],
        :notify => 'new_rule', 
        :status => 'success', 
        :property => params[:rule][:property],
        :value => params[:rule][:value]) 
    end
  end

  # PUT /rules/1
  # PUT /rules/1.json
  def update

    @rule = Rule.find(params[:id])

    if @rule.update_relevant_attributes(params[:rule])
      status = 'success'
    else
      status = 'failure'
    end

    redirect_to rules_path(
      :notify => 'new_rule', 
      :status => status,
      :_pjax => "data-pjax-container"
      )  

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

  private
  
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
