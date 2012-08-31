class Rule < ActiveRecord::Base
  include IceCube
  
  belongs_to  :consumer

  scope :money,     where("category = ?", "how much")
  scope :thresholds,where("category = ?", "thresholds")
  scope :what,      where("category = ?", "what")
  scope :time,      where("category = ?", "when")
  scope :location,  where("category = ?", "where")
  

  def schedule=(new_schedule)
    if new_schedule.nil?
      write_attribute(:schedule, nil)
    else
      write_attribute(:schedule, new_schedule.to_yaml)
    end
  end

  def schedule
    IceCube::Schedule.from_yaml(read_attribute(:schedule)) unless read_attribute(:schedule).nil?
  end

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

  def icon 
    if self.what?
      (i = Info.where("key = ? and value = ?", "rule", self.status).first) ? i.logo : nil
    else
      (i = Info.where("key = ? and value = ?", "rule", self.property).first) ? i.logo : nil  
    end
  end

  def title 
    if self.what?
      (i = Info.where("key = ? and value = ?", "rule", self.status).first) ? i.title : nil
    else
      (i = Info.where("key = ? and value = ?", "rule", self.property).first) ? i.title : nil  
    end
  end

  def money?
    self.category == "how much"
  end 
  
  def what?
    self.category == "what" 
  end
  
end
