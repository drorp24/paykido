class RegistrationsController < ApplicationController

  before_filter :check_and_restore_session  


  # GET /registrations
  # GET /registrations.json
  def index
    @registrations = @payer.registrations
  end


  # GET /registrations/1
  # GET /registrations/1.json
  def show
    @registration = Registration.find(params[:id])
  end

  # GET /registrations/new
  # GET /registrations/new.json
  def new
    redirect_to @payer.g2spp
  end

  # GET /registrations/1/edit
  def edit

  end

  # POST /registrations
  # POST /registrations.json

  # PUT /registrations/1
  # PUT /registrations/1.json
  def update
    @registration = Registration.find(params[:id])

    respond_to do |format|
      if @registration.update_attributes(params[:registration])
        format.html { redirect_to @registration, notice: 'Registration was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy

    respond_to do |format|
      format.html { redirect_to registrations_url }
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
        @registration = Registration.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such registration id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
