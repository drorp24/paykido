class ConsumerController < ApplicationController
  
  def login
        
  end
  #############################################
  
  def register_callback  
      
    find_or_create_consumer_and_payer     
    @payer.request_confirmation(@consumer)    

    redirect_to session[:referrer]  + '?status=' + 'registering'    

  end  
  
  def find_or_create_consumer_and_payer
    
    # A consumer instance may exist already (e.g., he once authorized Paykido and then unauthorized it)
    # A payer may already be associated with a consumer (e.g. above case)
    # A payer whose email was given may exist and not be linked to consumer (e.g. another brother joining) 
    
    if facebook_params_user_id = facebook_params['user_id']
      @consumer = Consumer.find_or_initialize_by_facebook_id(facebook_params_user_id)   
    elsif current_facebook_user # probably never true 
      @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)
    else                        # this is actually an error 
      @consumer = session[:consumer] || Consumer.new
    end 
    
    @payer = @consumer.payer || Payer.find_or_initialize_by_email(facebook_params['registration']['payer_email'])
    @payer.update_attributes(
          :name => facebook_params['registration']['payer_name'], 
          :email => facebook_params['registration']['payer_email'], 
          :phone => facebook_params['registration']['payer_phone'])
    @payer.password= "1"     # TEMP: till devise does it properly, payer's hashed_password is used as access token   
    @payer.save!

    @consumer.update_attributes!(
          :name => facebook_params['registration']['name'].split(' ')[0],
          :payer_id => @payer.id, 
          :billing_phone => facebook_params['registration']['consumer_phone'],
          :pic =>  "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture?type=large",
          :tinypic => "https://graph.facebook.com/" + facebook_params['user_id'] + "/picture")
   

    session[:consumer] = @consumer
    session[:payer] =    @payer
    
  end 

  #############################################
    
  def buy
  #  notify/approve/inform (make it DRY by having them all in the model)
                                              
    find_consumer_and_payer
    create_purchase  

    @purchase.authorize!
    
    if @purchase.authorized? 
      status = 'approved'                
      @purchase.pay_by_token!                                
      if @purchase.paid_by_token?
        @purchase.notify_merchant
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
      @purchase.notify_consumer('something', 'happenned') 
    end
    
    @purchase.notify_consumer('programmatic', status)

    redirect_to session[:referrer]  + '?status=' + status
    
  end
  
  def find_consumer_and_payer
    
    # ToDo: buy is no possible unless consumer has authorized (register_callback) Paykido
    # Consumer with that facebook id must exists after consumer registration. If not it's an error.
    @consumer = Consumer.find_or_initialize_by_facebook_id(params[:facebook_id])
    @consumer.name = params[:name]
    @consumer.pic =  params[:pic]
    @consumer.save!
    
    # ToDo: no session needed - delete
    session[:consumer] = @consumer
    @payer = session[:payer] = @consumer.payer unless @consumer.nil?
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
