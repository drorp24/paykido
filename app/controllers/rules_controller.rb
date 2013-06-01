class RulesController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_rule  


  # GET /rules
  # GET /rules.json
  def index

    @rules = (@consumer) ? @consumer.rules : current_payer.rules

    if current_payer.rules_require_registration
      @constraint = 'registration' 
    elsif !@consumer
      @constraint = 'consumer_level'
    end      

  end

  # GET /rules/1
  # GET /rules/1.json
  def show

    if current_payer.rules_require_registration
      render 'register_first'
    else
      @rule = Rule.find(params[:id])
      @consumer = @rule.consumer
      render 'new'
    end

  end
  
  # GET /rules/new
  # GET /rules/new.json
  def new
    
    if params[:property] == 'allowance' and params[:consumer_id] and last_allowance_rule = @consumer.allowance_rule 
      @rule = Rule.new_allowance_rule(last_allowance_rule)
    else
      @rule = Rule.new(:property => params[:property])
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
     @rule = Rule.create_new!(params[:rule], params[:id])
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
      occurrence = (params[:rule][:period] == 'weekly') ? @rule.weekly_occurrence : @rule.monthly_occurrence  
      redirect_to consumer_statistics_path(
        params[:rule][:consumer_id],
        :notify => 'new_rule', 
        :status => 'success', 
        :date => params[:rule][:date],
        :property => params[:rule][:property],
        :value => params[:rule][:value],
        :amount => params[:rule][:amount],
        :period => params[:rule][:period],
        :occurrence => occurrence) 
    end
  end

  # PUT /rules/1
  # PUT /rules/1.json
  def update

    @rule = Rule.find(params[:id])

    if @rule.allowance? 
      create 
      return
    end

    if @rule.update_attributes(params[:rule])
      status = 'success'
    else
      status = 'failure'
    end

    redirect_to consumer_statistics_path(
      params[:rule][:consumer_id],
      :notify => 'update_rule', 
      :status => status, 
      :update => 'set',
      :property => params[:rule][:property],
      :value => params[:rule][:value],
      :amount => params[:rule][:amount],
      :date => params[:rule][:date],
      :donator => params[:rule][:donator],
      :occasion => params[:rule][:occasion]) 

  end

  # PUT /rules/1/stop
  def stop

    @rule = Rule.find(params[:id])

    if @rule.expire
      status = 'success'
    else
      status = 'failure'
    end

    redirect_to consumer_rules_path(
      @rule.consumer_id,
      :notify => 'update_rule', 
      :status => status, 
      :update => 'stopped')
      
  end

  # PUT /rules/1/stop
  def restart

    @rule = Rule.find(params[:id])

    if @rule.restart
      status = 'success'
    else
      status = 'failure'
    end

    redirect_to consumer_rules_path(
      @rule.consumer_id,
      :notify => 'update_rule', 
      :status => status, 
      :update => 'restarted')
      
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule = Rule.find(params[:id])
    consumer = @rule.consumer
    @rule.destroy

    redirect_to consumer_rules_path(
      consumer.id,
      :notify => 'update_rule', 
      :status => 'success', 
      :update => 'removed')
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
