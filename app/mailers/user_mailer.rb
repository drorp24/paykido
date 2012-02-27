class UserMailer < ActionMailer::Base
  default :from => "info@paykido.com"
 
  def approval_email(purchase)

    @payer = purchase.payer
    @consumer = purchase.consumer
    @purchase = purchase

    email_with_name = "#{@payer.name} <#{@payer.email}>"
    begin
      mail(:to => email_with_name, :subject => "#{@consumer.name} asks you to approve a purchase")
    rescue
      return false
    else
      return "sent"
    end
  end
  
  def joinin_email(payer, consumer)

    @payer = payer
    @consumer = consumer

    email_with_name = "#{@payer.name} <#{@payer.email}>"
    begin
      mail(:to => email_with_name, :subject => "#{@consumer.name} wants you to know Paykido!")
    rescue
      return false
    else
      return "sent"
    end

  end
  
 end
