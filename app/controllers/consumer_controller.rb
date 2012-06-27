class ConsumerController < ApplicationController
  
  def login
    
    get_purchase_parameters
    find_or_create_consumer
    find_payer
    login_messages        
    
  end
  

  def login_callback
    
    login
    
    respond_to do |format|   
      format.js  
    end   
    
  end  

  def get_purchase_parameters
    
  
    if params[:demo] and params[:demo] == 'demo'
      session[:retailer] = 'zynga'             
      session[:title] = 'farmville'         
      session[:product] = params[:product].split('@')[0]
      session[:amount] = params[:product].split('@')[1]
      session[:demo] = true
    elsif params[:merchant]
      session[:retailer] = params[:merchant]
      session[:product] = params[:product]
      session[:amount] = params[:amount]
      session[:currency] = params[:currency]
      session[:userid] = params[:userid]
      session[:mode] = params[:mode]
      session[:hash] = params[:hash]
      session[:PP_TransactionID] = params[:PP_TransactionID]
      session[:referrer] = params[:referrer]
    end
    
    session[:params] = params
            
  end    

  def find_or_create_consumer
    
    begin
      if current_facebook_user
        @consumer = find_or_create_consumer_by_facebook_user
      else
        @consumer = session[:consumer] = nil 
      end 
    rescue Mogli::Client::OAuthException
        @consumer = session[:consumer] = nil 
    end         
    
  end
  

  def find_or_create_consumer_by_facebook_user
    
    @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)
    @consumer.name = @consumer.facebook_user.first_name
    @consumer.pic =  @consumer.facebook_user.large_image_url
    @consumer.tinypic = @consumer.facebook_user.image_url
    @consumer.allowance_every = 0 unless @consumer.allowance_every   # temp
    @consumer.save!
    
    session[:consumer] = @consumer
    
  end
  
  def find_payer
    @payer = session[:payer] = @consumer.payer unless @consumer.nil?
  end
  
  def login_messages
    
    if @consumer     
      @salutation = "Welcome "
      @name = @consumer.name + "!"  
      @pic = "https://graph.facebook.com/#{@consumer.facebook_id}/picture"      
      @first_line = "You selected #{session[:product]}"
      @second_line = "Click to buy it"
    else
      @salutation = "Hello!"
      @name = nil
      @pic = nil
      @first_line =  "You selected #{session[:product]}"
      @second_line = "Click Login or Register to start buying"
    end
    
  end      
       
  #############################################
  
  def register_callback  
      
    find_or_create_consumer_and_payer     
    @payer.request_confirmation(@consumer)    

    redirect_to :controller => :play, :action => :index    

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
  
  def create_purchase

    # note it depends on the kid staying in the same session
    # it would be better and provide better BI if purchase were created upon login, like consumer
     
    @purchase = session[:purchase] = 
    Purchase.create_new!(session[:payer], 
                         session[:consumer], 
                         session[:retailer], 
                         session[:title], 
                         session[:product], 
                         session[:amount], 
                         session[:currency], 
                         session[:PP_TransactionID],
                         session[:params])    

  end

  def authorization_messages
    
    if @purchase.authorized?
      @first_line = "#{session[:product]} is yours!"
      @second_line = "Thanks for using paykido"
    elsif @purchase.requires_approval?
      @first_line =  "This has to be approved by parent"
      @second_line = "Approval request has been sent"
    elsif @purchase.unauthorized? 
      @first_line = "This purchase is unauthorized"
      @second_line = "#{t @purchase.authorization_property}: #{@purchase.authorization_value} is #{t @purchase.authorization_type}"    
#   elsif !retailer_paid?
#     @first_line =  t 'payment_problem_1'
#     @second_line = t 'payment_problem_2'     
    end  
    
  end    
      
end
