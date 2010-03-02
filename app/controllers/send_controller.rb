require 'rubygems'
require 'clickatell'

class SendController < ApplicationController
  

  def sms
    api = Clickatell::API.authenticate('3224244', 'drorp24', 'dror160395')
    api.send_message('0542343220', 'Hello from clickatell')
  end
  
end
