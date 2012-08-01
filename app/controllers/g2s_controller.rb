class G2sController < ApplicationController

  before_filter :set_host_and_payer

  def ppp_callback    ## /ppp/<status>

    # no counting on any session - payer & purchase id are returned in the callback paramteres
    
    if params[:customField1] == 'payment'
        redirect_to payer_purchase_url(
          params[:customField2].to_i, 
          params[:customField3].to_i,
          :notify => 'approval', 
          :status => params[:status],
          :purchase => params[:customField3],
          :message => params[:message],
          :manual => 'true',
          :_pjax => "data-pjax-container"
        )
    elsif params[:customField1] == 'registration'
        redirect_to payer_purchases_path(
          params[:customField2].to_i, 
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

    return render(:nothing => true) if @local_test or @error
    
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
    
    render :nothing => true

  end


  private
  
  def set_host_and_payer
    
    if params[:customField1] == 'payment' and params[:nameOnCard] and params[:nameOnCard] == 'local'
      @local_test = true
      default_url_options[:host] = "localhost:3000"
      default_url_options[:protocol] = "http"
    else 
      default_url_options[:host] = Paykido::Application.config.hostname

      if params[:customField1] and params[:customField1] == 'registration'
        unless @payer =    Payer.find_by_id(params[:customField2].to_i)
          Rails.logger.debug("Payer whose id is #{params[:customField2]} was not found")
          @error = true
        end
      end
      
      if params[:customField1] and params[:customField1] == 'payment'
        unless @payer =    Payer.find_by_id(params[:customField2].to_i)
          Rails.logger.debug("Payer whose id is #{params[:customField2]} was not found")
          @error = true
        end
        unless @purchase = Purchase.find_by_id(params[:customField3].to_i)
          Rails.logger.debug("Purchase whose id is #{params[:customField3]} was not found")
          @error = true
        end
      end
    end
    
  end
  
end
