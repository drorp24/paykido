class Transaction < ActiveRecord::Base

  belongs_to  :purchase
  
  def create!(params)
    

    self.create!( :ppp_status =>  params[:ppp_status],
                  :PPP_TransactionID => params[:PPP_TransactionID],
                  :responsechecksum => params[:responsechecksum],
                  :TransactionID => params[:TransactionID],
                  :status => params[:status],
                  :userid => params[:userid],
                  :first_name => params[:first_name],
                  :last_name => params[:last_name],
                  :Email => params[:Email],
                  :address1 => params[:address1],
                  :address2 => params[:address2],
                  :country => params[:country],
                  :state => params[:state],
                  :city => params[:city],
                  :zip => params[:zip],
                  :phone1 => params[:phone1],
                  :nameOnCard => params[:nameOnCard],
                  :cardNumber => params[:cardNumber],
                  :expMonth => params[:expMonth],
                  :expYear => params[:expYear],
                  :token => params[:token],
                  :IPAddress => params[:IPAddress],
                  :ExErrCode => params[:ExErrCode],
                  :ErrCode => params[:ErrCode],
                  :AuthCode => params[:AuthCode],
                  :message => params[:message],
                  :responseTimeStamp => params[:responseTimeStamp],
                  :Reason => params[:Reason],
                  :ReasonCode => params[:ReasonCode]
                  )                                                      
    
    
  end
  
end
