class TokensController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_token  


  # GET /tokens
  # GET /tokens.json
  def index
    @tokens = current_payer.tokens
    redirect_to new_token_path(:notify => params[:notify]) unless @tokens.any?
  end


  # GET /tokens/1
  # GET /tokens/1.json
  def show

  end

  # GET /tokens/new
  # GET /tokens/new.json
  def new
    @token = Token.new
    redirect_to tokens_path(:notify => params[:notify]) if current_payer.tokens.any?
  end

  # GET /tokens/1/edit
  def edit

  end
  
  def create

    unless Paykido::Application.config.skip_g2s
      redirect_to current_payer.g2spp(params)
    else
      current_payer.tokens.create!(:CCToken => "DummyToken")
      consumer = current_payer.consumers.first

      Sms.notify_consumer(consumer, 'registration', 'done') if consumer

      pending = current_payer.purchases.pending
      if pending.any?
        purchase = pending.first
        redirect_to purchase_path(purchase.id, :activity => 'approval', :notify => 'registration', :status => 'success')
      else
        redirect_to consumer_rules_url(:consumer_id => consumer.id, :notify => 'registration', :status => 'success')
      end

    end
 
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

    for consumer in current_payer.consumers
      consumer.allowance_rule.expire if consumer.allowance_rule
    end

    redirect_to new_token_path(
      :notify => "unregistration", 
      :status => "success", 
      :_pjax => "data-pjax-container"
    )
 end

  private

  def find_token  
 
    if params[:id]
      begin    
        @token = current_payer.tokens.find(params[:id])    
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such token id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
