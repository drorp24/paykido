class G2sController < ApplicationController

  before_filter :set_host_and_payer

  def ppp_callback    ## /ppp/<status>

    # redirect to originating page according to context: registration or purchase
    # no counting on any session - payer & purchase id are returned in the callback paramteres
    
    if params[:customField1] == 'payment'
        redirect_to purchase_url(params[:customField2].to_i, params.except(:action, :controller))
    elsif params[:customField1] == 'registration'
#        redirect_to register_payer_url(params[:customField2].to_i, params.except(:action, :controller))
    else
      flash[:error] = ""
      redirect_to root_path
    end
        
  end
  
  def dmn
    # read dmn and store the properties in either a. registration or b. transaction
    # do not count on session to include anything to 'remind' of the context
    # instead, use the custom field to 'remind' the server what the context is
    
    # if this is a (succesful) transaction, notify/approve/inform (make it DRY by having them all in the model)
    # dont render anything or redirect anywhere

    if params[:customField1] == 'payment'
      @purchase.create_transaction!(params)
      # notify/approve/inform      
    elsif params[:customField1] == 'registration'
      a = 1 /0
#      @payer.create_registration!(params)
    else
      return false   
    end
    
  end


  private
  
  def set_host_and_payer
    
    if params[:customField1] and params[:customField1] == 'registration'
      @payer = Payer.find(params[:customField2])
    end
    
    if params[:customField1] and params[:customField1] == 'payment'
      @purchase = Purchase.find(params[:customField2])
    end
    
    if params[:nameOnCard] and params[:nameOnCard] == 'local'
      default_url_options[:host] = "localhost:3000"
    else 
     default_url_options[:host] = Paykido::Application.config.hostname
    end
  end
  
end
