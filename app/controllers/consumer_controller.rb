class ConsumerController < ApplicationController
  
  def login
        
  end
  #############################################
  
  def register_callback  
      
    find_or_create_consumer_and_payer     
    @payer.request_confirmation(@consumer)    

    redirect_to params[:referrer]  + '?status=' + 'registering'    

  end  
  
  def find_or_create_consumer_and_payer
    
    # A consumer instance may exist already (e.g., he once authorized Paykido and then unauthorized it)
    # A payer may already be associated with a consumer (e.g. above case)
    # A payer whose email was given may exist and not be linked to consumer (e.g. another brother joining) 
    
    Rails.logger.debug("ENTERS REGISTER CALLBACK")  

    if facebook_params_user_id = facebook_params['user_id']

      Rails.logger.debug("Facebook params (signed request/facebooker) user id is: " + facebook_params_user_id.to_s)  
      if c = Consumer.find_by_facebook_id(facebook_params_user_id)
        Rails.logger.debug("Consumer with that facebook id exists already. Its id is: " + c.id.to_s)
      else
        Rails.logger.debug("No consumer currently exists with that facebook id. Initialized record created")
      end

      @consumer = Consumer.find_or_initialize_by_facebook_id(facebook_params_user_id) 

    elsif current_facebook_user # probably never true 

      Rails.logger.debug("Facebook params (signed request/facebooker) passed no facebook user id, but current_Facebook_user exists")  

      @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)

    else                        # this is actually an error 

      Rails.logger.debug("Facebook params (signed request/facebooker) passed no facebook user id. No current_Facebook_user")  

      @consumer = session[:consumer] || Consumer.new

    end 
    
    if @consumer.payer == nil 
      Rails.logger.debug("@consumer.payer at that point is empty")
    else
      Rails.logger.debug("@consumer.payer already exists. Its id is: " + @consumer.payer_id.to_s)  
    end
    
    if p = Payer.find_by_email(facebook_params['registration']['payer_email'])  
      Rails.logger.debug("There is a payer with the form email of " + facebook_params['registration']['payer_email'])
      Rails.logger.debug("Its id is: " + p.id.to_s)
    else
      Rails.logger.debug("There isnt any payer with the form email of " + facebook_params['registration']['payer_email'])
    end   

    @payer = @consumer.payer || Payer.find_or_initialize_by_email(facebook_params['registration']['payer_email'])
    

    @payer.update_attributes(
          :name => facebook_params['registration']['payer_name'], 
          :email => facebook_params['registration']['payer_email'], 
          :phone => facebook_params['registration']['payer_phone'])
    @payer.password= "1"     # TEMP: till devise does it properly, payer's hashed_password is used as access token   
    @payer.save!

    Rails.logger.debug("The id of the payer that was updated/created is: " + @payer.id.to_s)
    Rails.logger.debug("The facebook param name is: " + facebook_params['registration']['payer_name'])
    Rails.logger.debug("Accordingly, I updated payer name to: " + @payer.name)

    @consumer.update_attributes!(
          :name => facebook_params['registration']['name'].split(' ')[0],
          :payer_id => @payer.id, 
          :billing_phone => facebook_params['registration']['consumer_phone'],
          :pic =>  "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture?type=large",
          :tinypic => "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture")
   
    Rails.logger.debug("Consumer is saved for the first time. Its id is: " + @consumer.id.to_s)
    Rails.logger.debug("The payer_id inserted into the consumer is: " + @consumer.payer_id.to_s)
    Rails.logger.debug("Consumer created_at got: " + @consumer.created_at.to_s)

    session[:consumer] = @consumer
    session[:payer] =    @payer
    
    Rails.logger.debug("EXISTS REGISTER CALLBACK")  
    
  end 

  #############################################
    
  def buy
  #  notify/approve/inform (make it DRY by having them all in the model)
                                              
    find_consumer_and_payer
    create_purchase  

    @purchase.authorize!
    
    if @purchase.authorized? 
      @purchase.pay_by_token!(request.remote_ip)                                
      if @purchase.paid_by_token?
        status = 'approved'                
        @purchase.approve!
        @purchase.account_for! 
      else
        status = 'failed'
      end             
    elsif @purchase.requires_approval?
      status = 'pending'
      @purchase.request_approval          
    elsif @purchase.unauthorized?
      status = 'declined'
    else             
      status = 'unknown' 
    end
    
    @purchase.notify_merchant(status) 
    @purchase.notify_consumer('programmatic', status)

    redirect_to params[:referrer] + 
      '?status=' +    status +
      '&property=' +  (@purchase.authorization_property || 'purchase') +
      '&value='  +    (@purchase.authorization_value ||  'okay') +
      '&type=' +      (@purchase.authorization_type || '')
    
  end
  
  def find_consumer_and_payer
    
    Rails.logger.debug("ENTERS BUY")  


    # ToDo: buy is no possible unless consumer has authorized (register_callback) Paykido
    # Consumer with that facebook id must exists after consumer registration. If not it's an error.

    Rails.logger.debug("The facebook id I received as parameter is: " + params[:facebook_id].to_s)
    if c = Consumer.find_by_facebook_id(params[:facebook_id])
      Rails.logger.debug("Consumer with that facebook id was found. Its id is: " + c.id.to_s)
    else
      Rails.logger.debug("Consumer with that facebook id was NOT found. So I initialized one.")      
    end  

    @consumer = Consumer.find_or_initialize_by_facebook_id(params[:facebook_id])
    @consumer.name = params[:name]
    @consumer.pic =  params[:pic]
    @consumer.save!

    Rails.logger.debug("Updated consumer name and pic. Its id is: " + @consumer.id.to_s)      
    
    # ToDo: no session needed - delete
    session[:consumer] = @consumer
    @payer = session[:payer] = @consumer.payer unless @consumer.nil?
    
    Rails.logger.debug("The payer Im using is the consumer payer. Its id is: " + @payer.id.to_s)      

  end


  def create_purchase

    # note it depends on the kid staying in the same session
    # it would be better and provide better BI if purchase were created upon login, like consumer
     
    @purchase = session[:purchase] = 
    Purchase.create_new!(@payer, 
                         @consumer, 
                         params[:merchant], 
                         params[:app], 
                         params[:product], 
                         params[:amount], 
                         params[:currency], 
                         params[:PP_TransactionID],
                         params)    

  end

end
