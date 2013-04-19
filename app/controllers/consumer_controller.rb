require 'digest/md5'
class ConsumerController < ApplicationController
    
  def login

  end
  
  def register
    
  end
  
  def confirmed

  respond_to do |format|
    
    consumer = Consumer.where("facebook_id = ?", params[:facebook_id])
    if consumer.exists? and consumer.first.confirmed?
      highest_inviter = Consumer.order("balance_on_acd DESC").first
      highest = {}
      highest[:name] = highest_inviter.name
      highest[:count] = highest_inviter.invites
      format.json { render json: {:status => 'confirmed', :invites => consumer.first.invites, :highest => highest} }
    else
      format.json { render json: {:status => 'not confirmed', :invites => 0, :highest => 0} }
    end
  end

  end
  
  def invites_increase

    respond_to do |format|
  
      consumer = Consumer.where("facebook_id = ?", params[:facebook_id]).first
      if consumer
        consumer.invites_increase(params[:invites])
        format.json { render json: {:invites_count => consumer.invites} }
      end
      
    end
  end
 
  #############################################
  
  def register_callback 
          
    unless correct(params)
      if params[:mode] == 'M'
         redirect_to "/play?status=wrong_params"
      else
        @response                 = {}
        @response[:status]        =    'failed' 
        @response[:property]      =  'parameters'
        @response[:value]         =    'wrong'
        render :layout => false 
      end      
      return      
    end

    find_or_create_consumer_and_payer  

    if @payer.errors.any?   
      Rails.logger.debug("@payer.errors is: " + @payer.errors.inspect.to_s)  
      flash[:error] = @payer.errors.inspect.to_s
      @payer.errors.clear 
      if params[:mode] == 'M'
        redirect_to params[:referrer]  + '?status=error'
      else
        @response                 = {}
        @response[:status]        =    'failed' 
        @response[:property]      =  'parent email'
        @response[:value]         =    'taken'
        render :layout => false
      end
    else
      @payer.request_confirmation(@consumer) 
      create_purchase
      @purchase.require_approval!
      if params[:mode] == 'M'
        redirect_to params[:referrer]  + '?status=registering'
      else
        @response = @purchase.response('registering')       
        render :layout => false 
      end
    end   

  end  
  
  def correct(params)
    if !params[:amount].blank? && !params[:merchant].blank? && !params[:product].blank? && !params[:currency].blank? && !params[:mode].blank? && !params[:PP_TransactionID].blank? && !params[:referrer].blank?
      return true
    else
      return false
    end
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

      @consumer = Consumer.find_by_facebook_id(facebook_params_user_id) 

      unless @consumer
        @consumer = Consumer.create!(:facebook_id => facebook_params_user_id)
      end

      unless @consumer.rules.any?
        @consumer.set_rules!(params)
      end

    elsif current_facebook_user # probably never true 

      Rails.logger.debug("Facebook params (signed request/facebooker) passed no facebook user id, but current_Facebook_user exists")  

      @consumer = Consumer.find_or_initialize_by_facebook_id(current_facebook_user.id)

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
    
    return unless @payer.save

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

    Rails.logger.debug("EXITS REGISTER CALLBACK")  
    
  end 

  #############################################
    
  def buy
                                              
    unless params[:facebook_id]
      Rails.logger.debug("No facebook_id in parameters")
      @response                 = {}
      @response[:status]        =    'failed' 
      @response[:property]      =  'facebook id'
      @response[:value]         =    'not supplied'
      render :layout => false       
      return
    end
    
    unless correct_hash(params)
      Rails.logger.debug("Wrong checksum")
      @response                 = {}
      @response[:status]        =    'failed' 
      @response[:property]      =  'checksum'
      @response[:value]         =    'wrong'
      render :layout => false       
      return      
    end

    find_consumer_and_payer

    unless @payer
      Rails.logger.debug("No @payer found")
      @response                 = {}
      @response[:status]        =    'unregistered' 
      render :layout => false 
      return
    end

    create_purchase  

    @purchase.authorize!
    
    if @purchase.authorized? 
      @purchase.pay_by_token!(request.remote_ip)                                
      if @purchase.paid_by_token?
        status = 'approved'                
        @purchase.account_for! 
      else
        status = 'failed'
        @purchase.failed!
      end             
    elsif @purchase.requires_approval?
      status = 'pending'
      @purchase.request_approval          
    elsif @purchase.unauthorized?
      status = 'declined'
    else             
      status = 'unknown' 
    end
    
    unless status == 'failed'
      notification_status = @purchase.notify_merchant(status, 'buy')
      status = 'failed' unless notification_status 
    end
    
    @response = @purchase.response(status)
       
    render :layout => false 
    
  end
  

  def correct_hash(params)
    
    return true unless (Paykido::Application.config.check_hash and params[:mode] != 'M')
    
    str =
      Paykido::Application.config.return_secret_key +
      params[:merchant] +
      (params[:app] || "") +
      params[:product] +
      params[:amount] +
      params[:currency] +
      (params[:userid] || "") +
      params[:mode] +
      params[:PP_TransactionID] +
      params[:referrer]
      
      expected_hash = Digest::MD5.hexdigest(str)
      Rails.logger.debug("expected_hash is: " + expected_hash) 
      
      expected_hash == params[:hash]

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
    @consumer.name = params[:name] if params[:name]
    @consumer.pic =  params[:pic] if params[:pic]
    @consumer.save!

    Rails.logger.debug("Updated consumer name and pic. Its id is: " + @consumer.id.to_s)      
    
    @payer = @consumer.payer unless @consumer.nil?
    
    Rails.logger.debug("The payer Im using is the consumer payer. Its id is: " + @payer.id.to_s) if @payer     

  end


  def create_purchase

    # note it depends on the kid staying in the same session
    # it would be better and provide better BI if purchase were created upon login, like consumer
     
    @purchase = 
    Purchase.create_new!(@payer, 
                         @consumer, 
                         params[:merchant], 
                         params[:app], 
                         params[:product], 
                         params[:amount], 
                         params[:currency], 
                         params[:PP_TransactionID],
                         params.except(:signed_request))    

  end

end
