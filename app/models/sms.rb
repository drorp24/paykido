require 'clickatell' 
class Sms < ActiveRecord::Base

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