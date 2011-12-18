class UserMailer < ActionMailer::Base
  default from: "info@paykido.com"
 
  def welcome_email(user, consumer_name)
    @user = user
    @url  = "http://" + request.host + ':' + request.port.to_s + "/service?name=" + user.name + "&invited_by=" + consumer_name
    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(:to => email_with_name, :subject => "Welcome to My Awesome Site")
  end
  
 end
