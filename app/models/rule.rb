class Rule < ActiveRecord::Base
  include IceCube
  
  belongs_to  :consumer

  ####  Change if needed      ####
  scope :monetary,    where("category = ?", "how much")
  scope :thresholds,  where("category = ?", "thresholds")
  scope :what,        where("category = ?", "what")
  scope :time,        where("category = ?", "when")
  scope :location,    where("category = ?", "where")
  
  def monetary?
    self.category == "how much"
  end 
  
  def what?
    self.category == "what" 
  end

  def self.allowance
    {:property => '_allowance', :category => "how much"}
  end
  def self.gift
    {:property => '_gift', :category => "how much"}
  end
  def self.birthday
    {:property => 'birthday', :category => "how much"}
  end  
  def self.chores
    {:property => 'chores', :category => "how much"}
  end  
   def self.request
    {:property => 'request', :category => "how much"}
  end  
  def self.achievment
    {:property => 'achievment', :category => "how much"}
  end  
  def self.retailer(consumer)
    {:property => 'retailer', :category => "what", :value => (consumer.payer.purchases.any?) ? consumer.payer.purchases.first.retailer.name : "Zynga" }
  end  
  def self.pegi_rating(consumer)
    {:property => 'pegi_rating', :category => "what", :value => (consumer.payer.purchases.any?) ? consumer.payer.purchases.first.properties['pegi_rating'] : "3" }
  end  
  def self.esrb_rating(consumer)
    {:property => 'esrb_rating', :category => "what", :value => (consumer.payer.purchases.any?) ? consumer.payer.purchases.first.properties['esrb_rating'] : "E" }
  end  
  def self.time
    {:property => 'time', :category => "when"}
  end  
  def self.location
    {:property => 'location', :category => "where", :value => "home"}
  end  
  def self.over
    {:property => 'over', :category => "when"}
  end  
  def self.under
    {:property => 'under', :category => "when"}
  end  

  def self.set_for!(consumer)
    consumer.rules.create!(self.allowance)
    consumer.rules.create!(self.gift)
    consumer.rules.create!(self.birthday)
    consumer.rules.create!(self.chores)
    consumer.rules.create!(self.request)
    consumer.rules.create!(self.achievment)
    consumer.rules.create!(self.retailer(consumer))
    consumer.rules.create!(self.pegi_rating(consumer))
    consumer.rules.create!(self.esrb_rating(consumer))
    consumer.rules.create!(self.time)
    consumer.rules.create!(self.location)
    consumer.rules.create!(self.over)
    consumer.rules.create!(self.under)
  end

  ####  Change if needed      ####  

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

  def info
  
    return @i if @calculated_already        # @i may be nil and this doesnt mean we have to calculated again if we have
    @calculated_already = true

    if self.what?
      @i = Info.where("key = ? and value = ?", "rule", self.status).first
    else
      @i = Info.where("key = ? and value = ?", "rule", self.property).first  
    end    
    
  end

  def icon 
    (i = self.info) ? i.logo : nil
  end

  def title 
    (i = self.info) ? i.title : nil
  end

  def description 
    (i = self.info) ? i.description : nil
  end

  def value_info
  
    return @vi if @vi_calculated_already        # @i may be nil and this doesnt mean we have to calculated again if we have
    @vi_calculated_already = true

    @vi = Info.where("key = ? and value = ?", self.property, self.value).first
    
  end
  
  def logo
    ((vi = self.value_info) && vi.logo) ? vi.logo : nil
  end

end
