class TransactionsController < ApplicationController

  before_filter :authenticate_payer!
  before_filter :find_transaction  

  def index
    @transactions = @purchase.transactions
  end

  def show

  end


  private

  def find_transaction  
 
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
        @transaction = @purchase.transactions.find(params[:id])  
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No such transaction id"
        redirect_to :controller => "home", :action => "routing_error"
        return
      end 
    end           

  end

end
