class ServiceController < ApplicationController

  def hello
    
  end
  
  def joinin
    @payer = find_payer    
  end
  
  def create_payer
 
    @payer = Payer.new(params[:payer])
    @payer.balance = 0
    @payer.exists = true
     session[:payer] = @payer

    if @payer.save
      rule = @payer.payer_rules.create(:rollover => 0, :billing_id => 1, :auto_authorize_under => 10, :auto_deny_over => 100)
      session[:rule] = rule
      flash[:notice] = "Thanks for joining us!"
      respond_to do |format|  
        format.html { redirect_to :action => :payer_signedin }  
        format.js 
      end
    else
      flash[:notice] = "We have some trouble getting this in... Please try again!"
      redirect_to :action => :joinin
    end 

  end
  
  def signin
    
   if request.post?
     
      payer = Payer.authenticate(params[:usr], params[:pwd])
      if payer
        session[:payer_id] = payer.id
        session[:retailer_id] = nil
        redirect_to :action => :payer_signedin
        return
      end
      
      retailer = Retailer.authenticate(params[:usr], params[:pwd])
      if retailer 
        session[:retailer_id] = retailer.id
        session[:payer_id] = nil
        redirect_to :action => :retailer_signedin
        return
      end

      flash[:notice] = "Invalid user/password combination"
      redirect_to :action => :index
      
   end
   
  end

  def payer_signedin
    
    @payer = find_payer
    @rule =  find_rule 
    
  end
  
  def retailer_signedin

    retailer_id = 1                # GET FROM SESSION (LOGGED IN)
     
    @sales = Purchase.retailer_sales(retailer_id)
    
    @categories = Purchase.retailer_top_categories(retailer_id)
    @i = 0
 
    
  end

 
  def payer_signedin
    
  end
  
  def jquery
    
  end
  
  def find_payer
    
    session[:payer]||=Payer.new
  end
  
  def find_rule
    
    @payer.most_recent_payer_rule
  end
end
