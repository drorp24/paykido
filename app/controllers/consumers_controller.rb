class ConsumersController < ApplicationController

  before_filter :check_and_restore_session  

  def confirm      

    if request.get?          
      render :index
    else
      @consumer.confirm!
      redirect_to payer_registrations_path(@payer)   
    end
    
  end

  # GET /consumers
  # GET /consumers.json
  def index
    @consumers = Consumer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @consumers }
    end
  end

  # GET /consumers/1
  # GET /consumers/1.json
  def show
    @consumer = Consumer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @consumer }
    end
  end

  # GET /consumers/new
  # GET /consumers/new.json
  def new
    @consumer = Consumer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @consumer }
    end
  end

  # GET /consumers/1/edit
  def edit
    @consumer = Consumer.find(params[:id])
  end

  # POST /consumers
  # POST /consumers.json
  def create
    @consumer = Consumer.new(params[:consumer])

    respond_to do |format|
      if @consumer.save
        format.html { redirect_to @consumer, notice: 'Consumer was successfully created.' }
        format.json { render json: @consumer, status: :created, location: @consumer }
      else
        format.html { render action: "new" }
        format.json { render json: @consumer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /consumers/1
  # PUT /consumers/1.json
  def update
    @consumer = Consumer.find(params[:id])

    respond_to do |format|
      if @consumer.update_attributes(params[:consumer])
        format.html { redirect_to @consumer, notice: 'Consumer was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @consumer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /consumers/1
  # DELETE /consumers/1.json
  def destroy
    @consumer = Consumer.find(params[:id])
    @consumer.destroy

    respond_to do |format|
      format.html { redirect_to consumers_url }
      format.json { head :ok }
    end
  end

  private

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
        @consumer = Consumer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such consumer id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      else
        unless @payer 
          @payer = @consumer.payer
          unless @payer.id == session[:payer_id]
            flash[:error] = "Please log in first"
            redirect_to login_path
            return
          end
        end
      end 
    end           

  end


end