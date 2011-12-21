class UserMailer < ActionMailer::Base
  default :from => "info@paykido.com"
 
  def joinin_email(user, consumer)

    @user = user
    @consumer = consumer
    @url  = url_for(:controller => "service", :action => "invite") + "?name=" + @user.name + "&authenticity_token=" + @user.hashed_password + "&email=" + @user.email + "&invited_by=" + @consumer.name

    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(:to => email_with_name, :subject => "Join Paykido!")

  end
  
 end
