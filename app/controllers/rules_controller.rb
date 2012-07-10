class RulesController < ApplicationController

  before_filter :check_and_restore_session  


  # GET /rules
  # GET /rules.json
  def index
    @rules = (@consumer) ? @consumer.rules : @payer.rules
  end

  # GET /rules/1
  # GET /rules/1.json
  def show

  end

  # GET /rules/new
  # GET /rules/new.json
  def new
    @rule = Rule.new
  end

  # GET /rules/1/edit
  def edit

  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        format.html { redirect_to payer_rules_path(@payer), notice: 'Rule was successfully created.' }
        format.json { render json: @rule, status: :created, location: @rule }
      else
        format.html { render action: "new" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
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

  
  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    super
    if flash[:error]
      redirect_to login_path 
      return
    end
    
    if params[:id]
      begin    
        @rule = Rule.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such rule id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end