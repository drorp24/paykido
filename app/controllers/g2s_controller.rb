class G2sController < ApplicationController

  before_filter :set_host_and_payer

  def ppp_callback    ## /ppp/<status>

    # redirect to originating page according to context: registration or purchase
    # no counting on any session - payer & purchase id are returned in the callback paramteres
    
    if params[:customField1] == 'payment'
        redirect_to payer_purchases_url(
          @payer, 
          :notify => 'approval', 
          :status => params[:status],
          :retailer => @purchase.retailer.name,
          :approval_counter => @purchase.approval_counter('retailer') 
        )
    elsif params[:customField1] == 'registration'
        redirect_to payer_purchases_path(
          @payer, 
          :notify => 'registration', 
          :status => params[:status]
        )
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
      if params[:Status] == 'APPROVED'
        status = 'approved' 
        @purchase.approve!
        @purchase.account_for!
      else
        status = 'failed'
      end   
      @purchase.notify_merchant(status)
      @purchase.notify_consumer('manual', status)

    elsif params[:customField1] == 'registration'
      
      @payer.create_registration!(params)
    
    else
      return false   
    end
    
    
  end


  private
  
  def set_host_and_payer
    
    if params[:customField1] and params[:customField1] == 'registration'
      @payer = Payer.find(params[:customField2].to_i)
    end
    
    if params[:customField1] and params[:customField1] == 'payment'
      @purchase = Purchase.find(params[:customField2].to_i)
      @payer = @purchase.payer
    end
    
    if params[:nameOnCard] and params[:nameOnCard] == 'local'
      default_url_options[:host] = "localhost:3000"
    else 
     default_url_options[:host] = Paykido::Application.config.hostname
    end
  end
  
end
