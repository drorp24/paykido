class Rule < ActiveRecord::Base

  belongs_to :consumer


  def self.set!(params) 

#    rule = self.where(params.except[:authenticity_token]).first_or_initialize    # as of Rails 3.2.1
    rule = self.find_or_initialize_by_consumer_id_and_property_and_value(
      :consumer_id => params[:consumer_id],
      :property => params[:property],
      :value => params[:value]
      )
      rule.update_attributes!(:status => params[:rule_status])
  end
  
  def self.set?(params)
    self.where(params).exists?
  end


end
