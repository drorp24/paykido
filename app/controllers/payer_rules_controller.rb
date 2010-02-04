class PayerRulesController < ApplicationController
  # GET /payer_rules
  # GET /payer_rules.xml
  def index
    @payer_rules = PayerRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payer_rules }
    end
  end

  # GET /payer_rules/1
  # GET /payer_rules/1.xml
  def show
    @payer_rule = PayerRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payer_rule }
    end
  end

  # GET /payer_rules/new
  # GET /payer_rules/new.xml
  def new
    @payer_rule = PayerRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payer_rule }
    end
  end

  # GET /payer_rules/1/edit
  def edit
    @payer_rule = PayerRule.find(params[:id])
  end

  # POST /payer_rules
  # POST /payer_rules.xml
  def create
    @payer_rule = PayerRule.new(params[:payer_rule])

    respond_to do |format|
      if @payer_rule.save
        flash[:notice] = 'PayerRule was successfully created.'
        format.html { redirect_to(@payer_rule) }
        format.xml  { render :xml => @payer_rule, :status => :created, :location => @payer_rule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payer_rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payer_rules/1
  # PUT /payer_rules/1.xml
  def update
    @payer_rule = PayerRule.find(params[:id])

    respond_to do |format|
      if @payer_rule.update_attributes(params[:payer_rule])
        flash[:notice] = 'PayerRule was successfully updated.'
        format.html { redirect_to(@payer_rule) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payer_rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payer_rules/1
  # DELETE /payer_rules/1.xml
  def destroy
    @payer_rule = PayerRule.find(params[:id])
    @payer_rule.destroy

    respond_to do |format|
      format.html { redirect_to(payer_rules_url) }
      format.xml  { head :ok }
    end
  end
end
