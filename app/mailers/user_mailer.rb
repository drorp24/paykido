class UserMailer < ActionMailer::Base
  default :from => "info@paykido.com"
 
  def joinin_email(user, consumer)

    @user = user
    @consumer = consumer

    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(:to => email_with_name, :subject => "#{@consumer.name} wants you to know Paykido!")

  end
  
 end
