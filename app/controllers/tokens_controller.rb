class TokensController < ApplicationController

  before_filter :check_and_restore_session  


  # GET /tokens
  # GET /tokens.json
  def index
    @tokens = @payer.tokens
    redirect_to new_payer_token_path(@payer) unless @tokens.any?
  end


  # GET /tokens/1
  # GET /tokens/1.json
  def show

  end

  # GET /tokens/new
  # GET /tokens/new.json
  def new
    @token = Token.new
  end

  # GET /tokens/1/edit
  def edit

  end
  
  def create
    redirect_to @payer.g2spp(params) 
  end

  # POST /tokens
  # POST /tokens.json

  # PUT /tokens/1
  # PUT /tokens/1.json
  def update
    @token = Token.find(params[:id])

    respond_to do |format|
      if @token.update_attributes(params[:token])
        format.html { redirect_to @token, notice: 'Token was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tokens/1
  # DELETE /tokens/1.json
  def destroy
    @token.destroy
    redirect_to new_payer_token_path(
      @payer,
      :notify => "unregistration", 
      :status => "success", 
      :_pjax => "data-pjax-container"
    )
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
        @token = @payer.tokens.find(params[:id])    ## replace @payer with current_user
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such token id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
