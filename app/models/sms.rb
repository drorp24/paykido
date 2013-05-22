require 'clickatell' 
class Sms < ActiveRecord::Base

  def self.notify_consumer (consumer, activity, status, purchase=nil, mode=nil)
      
    if    activity == 'confirmation'
      if status == 'request'
        message = "Hi #{consumer.name}. We just sent your parent an email asking to confirm you. Once confirmed, click Paykido again and start buying!"
      elsif status == 'done'
        message = "Congrats! Your parent has just confirmed you. Go ahead and click to buy!"
      end
    elsif activity == 'registration' and status == 'done'
        message = "Congrats, #{consumer.name}! Your parent has just registered to Paykido!"
    elsif activity == 'approval'
      if mode == 'manual'
        source = 'Your parent'
      else
        source = 'Paykido'
      end
      if status == 'request'
        message = "We have asked your parent to approve #{purchase.product}. You will get a text message once your parent approves."
      elsif      status == 'approved'
        message = "Congrats, #{consumer.name}! #{source} has just approved your purchase request (#{purchase.id}). The item is yours!"
      elsif    status == 'declined'  
        message = "We are sorry. #{source} has just declined your purchase request (#{purchase.id})."
      elsif   status == 'failed'  
        message = "We are sorry. Something went wrong while trying to approve your purchase (#{purchase.id}). Please contact Paykido help desk for details"  
      else
        return false  
      end 
    end 
    
    begin
      self.send(consumer.billing_phone, message) 
    rescue
      return false
    end
 
  end     


  def self.send(phone, message)

    return unless Paykido::Application.config.send_sms
    
    begin
      api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
      api.send_message(phone, message)
    rescue 
      return false
    end
    
  end

end
