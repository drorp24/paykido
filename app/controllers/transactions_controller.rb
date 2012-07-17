class TransactionsController < ApplicationController

  before_filter :check_and_restore_session  

  def index
    @transactions = @purchase.transactions
  end

  def show

  end


  private
  
  def check_and_restore_session  
 
    # Have Devise run the user session 
    # Every call should include payer_id, consumer_id and/or purchase_id
    
    super
    if flash[:error]
      redirect_to login_path 
      return
    end
    
    if params[:purchase_id]
      begin    
        @purchase = Purchase.find(params[:purchase_id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such purchase id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

    if params[:id]
      begin    
        @transaction = Transaction.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such transaction id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
