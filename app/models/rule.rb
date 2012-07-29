class Rule < ActiveRecord::Base

  belongs_to :payer
  belongs_to :consumer


  def self.set!(params) 

#    rule = self.where(parameters).first_or_create!    # as of Rails 3.2.1
    rule = self.find_or_create_by_payer_id_and_consumer_id_and_property_and_value_and_status(
      :payer_id => params[:payer_id],
      :consumer_id => params[:consumer_id],
      :payer_id => params[:payer_id],
      :property => params[:property],
      :value => params[:value],
      :status => params[:status]
      )
  end
  
  def self.set?(params)
    self.where(params).exists?
  end


end
