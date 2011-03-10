require 'rubygems'
require 'openssl'
require 'base64'
#require 'yajl'
#require 'ruby-debug'

class LoginController < ApplicationController
  
  def login
    
  end
  
  def register
        
  end
    
  end
  
  def register_callback
    
    facebook = FacebookRegistration::SignedRequest.new
    parsed_params = facebook.call(params["signed_request"])
    puts parsed_params.inspect 
#   parsed_params["registration"]["message"]
#   insert these details into the payer record and create an SMS! Dad, please..... [kid's name]
#   update the payer record and subscriber record now, and create a unique url directly to the acct
#   there, insert the paypal authorization and/or billing selection into the 'wizard'.
#   once the parent finishes this step, the payer status changes to 'exists' and the kid gets an SMS
    
    set_consumer_and_payer
    redirect_to :controller => 'consumer', :action => 'main'
    
  end

  def set_consumer_and_payer

     @consumer = Consumer.find_by_facebook_id(current_facebook_user.id)
     unless @consumer
        begin
          @consumer = Consumer.new(:facebook_id => current_facebook_user.id)
          @consumer.payer = Payer.new(:exists => false)
          @consumer.save!
        rescue #RecordInvalid 
          flash[:notice] = "Consumer and/or payer didn't pass validation"
         puts "Consumer and/or payer didn't pass validation"
        end 
     end
     @payer = @consumer.payer
     @consumer_rule = @consumer.most_recent_payer_rule if @payer.exists
     session[:consumer] = @consumer
     session[:consumer_rule] = @consumer_rule 
     session[:facebook_id] = @consumer.facebook_id
     session[:payer] = @payer
     
  end



module FacebookRegistration
  class SignedRequest
    def initialize
    end

  def call(params)
    if params.is_a?(Hash)
      signed_request = params.delete('signed_request')
    else
      signed_request  = params
    end

    unless signed_request
      return Rack::Response.new(["Missing signed_request param"], 400).finish
    end

    signature, signed_params = signed_request.split('.')
#    signed_params = Yajl::Parser.new.parse(base64_url_decode(signed_params))

    return signed_params
  end

  private

    def signed_request_is_valid?(secret, signature, params)
      signature = base64_url_decode(signature)
      expected_signature = OpenSSL::HMAC.digest('SHA256', secret, params.tr("-_", "+/"))
      return signature == expected_signature
    end

    def base64_url_decode(str)
      str = str + "=" * (6 - str.size % 6) unless str.size % 6 == 0
      return Base64.decode64(str.tr("-_", "+/"))
    end
  end
end



