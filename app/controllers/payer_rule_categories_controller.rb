class PayerRuleCategoriesController < ApplicationController
  # GET /payer_rule_categories
  # GET /payer_rule_categories.xml
  def index
    @payer_rule_categories = PayerRuleCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payer_rule_categories }
    end
  end

  # GET /payer_rule_categories/1
  # GET /payer_rule_categories/1.xml
  def show
    @payer_rule_category = PayerRuleCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payer_rule_category }
    end
  end

  # GET /payer_rule_categories/new
  # GET /payer_rule_categories/new.xml
  def new
    @payer_rule_category = PayerRuleCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payer_rule_category }
    end
  end

  # GET /payer_rule_categories/1/edit
  def edit
    @payer_rule_category = PayerRuleCategory.find(params[:id])
  end

  # POST /payer_rule_categories
  # POST /payer_rule_categories.xml
  def create
    @payer_rule_category = PayerRuleCategory.new(params[:payer_rule_category])

    respond_to do |format|
      if @payer_rule_category.save
        flash[:notice] = 'PayerRuleCategory was successfully created.'
        format.html { redirect_to(@payer_rule_category) }
        format.xml  { render :xml => @payer_rule_category, :status => :created, :location => @payer_rule_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payer_rule_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payer_rule_categories/1
  # PUT /payer_rule_categories/1.xml
  def update
    @payer_rule_category = PayerRuleCategory.find(params[:id])

    respond_to do |format|
      if @payer_rule_category.update_attributes(params[:payer_rule_category])
        flash[:notice] = 'PayerRuleCategory was successfully updated.'
        format.html { redirect_to(@payer_rule_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payer_rule_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payer_rule_categories/1
  # DELETE /payer_rule_categories/1.xml
  def destroy
    @payer_rule_category = PayerRuleCategory.find(params[:id])
    @payer_rule_category.destroy

    respond_to do |format|
      format.html { redirect_to(payer_rule_categories_url) }
      format.xml  { head :ok }
    end
  end
end
