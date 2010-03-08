require 'ruby-debug'
class AolController < ApplicationController
  
  def main
    
  end
  
  def protect
    
  end
  
  def welcome_new

  end

  def welcome_signedin
    
  end
  
  def signin
    
   if request.post?
      payer = Payer.authenticate(params[:payer][:user], params[:payer][:password])
      unless payer
        flash[:notice] = "Invalid user/password combination"
        return
      end
      rule = payer.most_recent_payer_rule
      if rule
        session[:payer_id] = payer.id
        session[:payer_user] = payer.user                         # do I use it?
        session[:rule_id] = rule
        flash[:notice] = "What would you like to do?"
        redirect_to :action => :welcome_signedin
      else
        flash[:notice] = "No rule set for this payer"
        redirect_to :action => :joinin
      end
   end
   
  end
  
  def joinin
    
  end
  
  def create
    payer = Payer.new(params[:payer])
    payer.balance = 0

    if payer.save
      session[:payer_id] = payer.id
      session[:payer_user] = payer.user                            # do I use it?
      rule = payer.payer_rules.create(:rollover => 0, :billing_id => 1)
      session[:rule_id] = rule.id
      flash[:notice] = "Thank you. You may define your rules now"
      redirect_to :action => :welcome_signedin
    else
      render :action => "joinin"
    end

  end

  def account_form        # decide if I want a rescue like this in other activities or assume you never start here
    
    begin
    @payer = Payer.find(session[:payer_id])
    rescue #RecordNotFound
    redirect_to :action => :welcome_new
    else
    flash.now[:notice] = "You can change any of the following:"
    end
  
  end 
 
  def account_update
    payer = Payer.find(session[:payer_id])
    
    if payer.update_attributes(params[:payer]) 
      flash[:notice] = "Thank you"
      redirect_to :action => :welcome_signedin
    else
      render :action => "account_form"
    end
  end
  
  def rules_menu
    
  end
  
  def budget_form
    @payer = Payer.find(session[:payer_id])
    @rule = @payer.most_recent_payer_rule
  end
  
  def budget_update
    
    @payer = Payer.find(session[:payer_id])
    @rule = @payer.most_recent_payer_rule
    unless @rule
      flash[:notice] = "No rule set for this payer"
      redirect_to :action => :joinin
      return
    end
    
    if @rule.update_attributes(params[:rule])
      debugger
      flash[:notice] = "Rule updated!"
      redirect_to :action => :rules_menu
    else
      flash[:notice] = "Something wrong happened"
      render :action => :rules_menu
    end
    
  end

 
   def logout
    session[:payer_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
 
 end
