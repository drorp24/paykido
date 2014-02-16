class G2sController < ApplicationController

  before_filter :set_host_and_payer

  def ppp_callback    ## /ppp/<status>

    if params[:customField1] == 'payment'

      # Mark purchase approved already upon ppp_callback so the purchase will be marked approved and disappear from the screen
      # When DMN returns, it will be marked approved again, a transaction will be created and the purchase will be accounted for

      @purchase = Purchase.find(params[:customField3].to_i)

      if (params[:ppp_status] == 'OK' and @purchase) or Paykido::Application.config.skip_g2s
        @purchase.approve!
        if @purchase.approved?
          notification_status = @purchase.notify_merchant('approved', 'buy')
          if notification_status == "OK"
            @purchase.account_for!
            status = 'approved'
          else
            @purchase.notification_failed!
            status = 'failed'
          end
          Sms.notify_consumer(@purchase.consumer, 'approval', status, @purchase, 'manual')
        else 
          Sms.notify_consumer(@purchase.consumer, 'approval', 'failed', @purchase, 'manual')
        end
      else
        Sms.notify_consumer(@purchase.consumer, 'approval', 'failed', @purchase, 'manual')          
      end

      redirect_to purchase_url(
        params[:customField3].to_i,
        :notify => 'approval', 
        :status => params[:status],
        :ppp_status => params[:ppp_status],
        :purchase => params[:customField3],
        :ErrCode => params[:ErrCode],
        :ExErrCode => params[:ExErrCode],
        :manual => 'true',
        :notification_status => notification_status,
        :_pjax => "data-pjax-container"
      )

    elsif params[:customField1] == 'registration'
          
        # A temporary token is created immediately after PPP and consumer notified here, to enable kid to buy instantly
        if params[:ppp_status] == 'OK' and params[:Status] == 'APPROVED'
          @payer.create_temporary_token!(params)
          consumer = @payer.consumers.first
          Sms.notify_consumer(consumer, 'registration', 'done') if consumer
        end

        pending = @payer.purchases.pending
        if pending.any?
          purchase = pending.first
          redirect_to purchase_path(purchase.id, :activity => 'approval', :notify => 'registration', :status => params[:status])
        else
          consumer = @payer.consumers.first
          redirect_to consumer_rules_url(:consumer_id => consumer.id, :notify => 'registration', :status => params[:status])
        end

    elsif params[:status] == 'back'     # when back is clicked, that's the only parameter G2S returns
          redirect_to purchases_url
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

      # CURRENTLY DMN ONLY WRITE TRANSACTION. EVERYTHING ELSE (INCL. NOTIFICATION) IS DONE ALREADY AFTER PPP_CALLBACK
      @purchase.create_transaction!(params)

    elsif params[:customField1] == 'registration'
      
      @payer.create_token!(params)                      #ToDo: it looks like it needs to verify the status is OK like above
    
    end
    
    render :nothing => true

  end

  def TestPaykidoNotificationListener
    Rails.logger.info ""
    Rails.logger.info "TestPaykidoNotificationListener called."
    Rails.logger.info ""
    Rails.logger.info "request IP:    #{request.remote_ip}"
    Rails.logger.info "orderid:       #{params[:orderid]}"
    Rails.logger.info "status:        #{params[:status]}"
    Rails.logger.info "purchase_id:   #{params[:purchase_id]}"
    Rails.logger.info ""

    render :nothing => true
  end

  private
  
  def set_host_and_payer
    
    if params[:customField1] == 'payment' and params[:nameOnCard] and params[:nameOnCard] == 'dev'
      @local_test = true
      default_url_options[:host] = "localhost:3000"
      default_url_options[:protocol] = "http"
    elsif params[:customField1] == 'payment' and params[:nameOnCard] and params[:nameOnCard] == 'staging'
      @local_test = true
      default_url_options[:host] = "paykido-staging.herokuapp.com"
      default_url_options[:protocol] = "http"
    elsif params[:customField1] == 'payment' and params[:nameOnCard] and params[:nameOnCard] == 'testing'
      @local_test = true
      default_url_options[:host] = "paykido-testing.herokuapp.com"
      default_url_options[:protocol] = "http"
    else 
      default_url_options[:host] = Paykido::Application.config.hostname

      if params[:customField1] and params[:customField1] == 'registration'
        unless @payer =    Payer.find_by_id(params[:customField2].to_i)
          Rails.logger.info("Payer whose id is #{params[:customField2]} was not found")
          @error = true
        end
      end
      
      if params[:customField1] and params[:customField1] == 'payment'
        unless @payer =    Payer.find_by_id(params[:customField2].to_i)
          Rails.logger.info("Payer whose id is #{params[:customField2]} was not found")
          @error = true
        end
        unless @purchase = Purchase.find_by_id(params[:customField3].to_i)
          Rails.logger.info("Purchase whose id is #{params[:customField3]} was not found")
          @error = true
        end
      end
    end
    
  end
  
end
