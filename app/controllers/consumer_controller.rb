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
    
    if params[:mode] and params[:mode] == 'demo'
      session[:retailer] = 'zynga'             
      session[:title] = 'farmville'         
      session[:product] = params[:product].split('@')[0]
      session[:price] = params[:product].split('@')[1]
    elsif params[:merchant]
      session[:retailer] = params[:merchant]
      session[:title] = params[:app]
      session[:product] = params[:product]
      session[:price] = params[:amount]
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
      @second_line = "Login or register, then click to buy"
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
                                              
    create_purchase  

    @purchase.authorize!
    if @purchase.authorized?                        
#     @purchase.pay!                                  
      @purchase.account_for!  # if @purchase.paid?       
    elsif @purchase.requires_approval?
      @purchase.request_approval          
    end
    
    authorization_messages      
    
    respond_to do |format|  
      format.js  
    end
    
  end
  
  def create_purchase
    @purchase = session[:purchase] = 
    Purchase.create_new!(session[:payer], session[:consumer], session[:retailer], session[:title], session[:product], session[:price], session[:params])    
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
