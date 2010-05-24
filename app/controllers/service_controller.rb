class ServiceController < ApplicationController

  def hello
    
  end
  
  def joinin
    

  end
  
  def create_retailer

    @retailer = Retailer.new(params[:retailer])
    if @retailer.save
      session[:retailer_id] = @retailer.id
      flash[:notice] = "Thanks for joining us!"  
      respond_to do |format|  
        format.html { redirect_to :action => :retailer_signedin }  
        format.js 
      end
    else
      msg = ""

      msg += "name " + @retailer.errors.on(:name) if @retailer.errors.on(:name)
      msg += " user " + @retailer.errors.on(:user) if @retailer.errors.on(:user)
      msg += " password " + @retailer.errors.on(:password)if @retailer.errors.on(:password)
      flash[:notice] = msg
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
    
  end
  
  def retailer_signedin

    retailer_id = 1                # GET FROM SESSION (LOGGED IN)
     
    @sales = Purchase.retailer_sales(retailer_id)
    
    @categories = Purchase.retailer_top_categories(retailer_id)
    @i = 0
 
    
  end

  
  def jquery
    
  end
end
