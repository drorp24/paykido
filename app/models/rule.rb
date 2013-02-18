class Rule < ActiveRecord::Base
  include IceCube

  belongs_to  :consumer

  def self.new_allowance_rule(last_allowance_rule)
    rule = self.new
    rule.consumer_id =      last_allowance_rule.consumer_id,
    rule.property =         last_allowance_rule.property,
    rule.value =            last_allowance_rule.value,
    rule.status =           last_allowance_rule.status,
    rule.schedule =         last_allowance_rule.schedule,
    rule.occasion =         last_allowance_rule.occasion,
    rule.donator =          last_allowance_rule.donator,
    rule.category =         last_allowance_rule.category,
    rule.previous_rule_id = last_allowance_rule.id
    rule  
  end

  def self.create_new!(params)

    if params[:previous_rule_id] 
      expired_rule = self.find(params[:previous_rule_id])
      expired_rule.expire!
    end

    schedule = IceCube::Schedule.new 
    if params[:period] ==  'weekly'
      schedule.add_recurrence_rule Rule.weekly.day(params[:weekly_occurrence].to_i) 
    elsif params[:period] ==  'monthly'
      schedule.add_recurrence_rule Rule.monthly.day_of_month(params[:monthly_occurrence].to_i) 
    elsif params[:period] ==  'yearly'
    elsif params[:period] ==  'daily'
    elsif params[:period] == 'nonrecurring'
    else
      schedule = nil
    end

    rule = self.new(:consumer_id => params[:consumer_id], :property => params[:property], :value => params[:value])  
    rule.schedule = schedule
    rule.save   
    rule
    
  end

  # Dummy property. Lives between 'new' and 'create'
  def previous_rule_id
    @previous_rule_id if @previous_rule_id
  end
  
  def previous_rule_id=(rule_id)
    @previous_rule_id = rule_id
  end

  ####  Change if needed      ####
  scope :monetary,    where("category = ?", "how much")
  scope :thresholds,  where("category = ?", "thresholds")
  scope :what,        where("category = ?", "what")
  scope :time,        where("category = ?", "when")
  scope :location,    where("category = ?", "where")
  
  scope :of_allowance,   where("property = ?", "_allowance")
  
  def monetary?
    self.category == "how much"
  end 
  
  def what?
    self.category == "what" 
  end
 
  def allowance?
    self.property == "_allowance"
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
    {:property => 'retailer', :category => "what", :status => 'whitelisted', :value => (consumer.purchases.any?) ? consumer.purchases.last.retailer.name : "Zynga" }
  end  
  def self.pegi_rating(consumer)
    {:property => 'pegi_rating', :category => "what", :status => 'whitelisted', :value => (consumer.purchases.any?) ? consumer.purchases.last.properties['pegi_rating'] : "3" }
  end  
  def self.esrb_rating(consumer)
    {:property => 'esrb_rating', :category => "what", :status => 'whitelisted', :value => (consumer.purchases.any?) ? consumer.purchases.last.properties['esrb_rating'] : "E" }
  end  
  def self.time1
    {:property => 'time', :category => "when"}
  end  
  def self.location1
    {:property => 'location', :category => "where", :value => "home"}
  end  
  def self.over
    {:property => 'over', :category => "thresholds"}
  end  
  def self.under
    {:property => 'under', :category => "thresholds"}
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
    consumer.rules.create!(self.time1)
    consumer.rules.create!(self.location1)
    consumer.rules.create!(self.over)
    consumer.rules.create!(self.under)
  end

  ####  Change if needed      ####  

  def self.allowance_rule_of(consumer)
    applicable_rules = self.where("consumer_id = ? and property = ?", consumer.id, '_allowance')
    if applicable_rules.any?
      allowance_rule = applicable_rules.last          # ToDo: think!
    else
      nil
    end
  end

  # ToDo: DELETE. Use only the rule object, dont create a special hash, just reducndant.
  def self.allowance_of(consumer)
    applicable_rules = self.where("consumer_id = ? and property = ?", consumer.id, '_allowance')
    if applicable_rules.any?
      allowance_rule = applicable_rules.last          # ToDo: think!
      { :amount => val = allowance_rule.value.to_i, 
        :period => allowance_rule.period,
        :weekly_occurrence => allowance_rule.weekly_occurrence,
        :monthly_occurrence => allowance_rule.monthly_occurrence,
        :start_date => allowance_rule.schedule.start_time,
        :number_of_grants => grants = allowance_rule.schedule.occurrences(Time.now).count,
        :so_far_accumulated => grants * val }
    else
      nil
    end
  end
  
  def expire!
    new_schedule = self.schedule || IceCube::Schedule.new
    new_schedule.end_time = Time.now
    self.schedule = new_schedule
    self.save
  end

  def expired?
    self.schedule.end_time
  end

  def update_relevant_attributes(params)
    
    if params[:period] == 'Monthly'
      self.update_attributes(
        :value => params[:value],
        :period => params[:period],
        :monthly_occurrence => params[:monthly_occurrence]
        )
    elsif params[:period] == 'Weekly'
      self.update_attributes(
        :value => params[:value],
        :period => params[:period],
        :weekly_occurrence => params[:weekly_occurrence]
        )
    else
       self.update_attributes(params)         
    end
    
  end

  ################ ICE_CUBE SCHEDULING ########################################3
  ################ Currently, not tolerant to input errors#####################3

  # Atomic methods, should have been defined by IceCube

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
    
  def recurring?
    self.schedule.recurrence_rules.any? if self.schedule
  end  

  def yearly?
    self.recurring? and self.schedule.to_hash[:rrules][0][:rule_type] == "IceCube::YearlyRule"
  end
  
  def monthly?   
    self.recurring? and self.schedule.to_hash[:rrules][0][:rule_type] == "IceCube::MonthlyRule"
  end
  
  def weekly?   
    self.recurring? and self.schedule.to_hash[:rrules][0][:rule_type] == "IceCube::WeeklyRule"
  end
  
  def daily?   
    self.recurring? and self.schedule.to_hash[:rrules][0][:rule_type] == "IceCube::DailyRule"
  end
  
  def nonrecurring?
    !self.recurring?
  end
  
  def period

    return @period if @period

    if self.weekly?
      'weekly'
    elsif self.monthly?
      'monthly'
    elsif self.daily?
      'daily'
    elsif self.yearly?
      'yearly'
    elsif self.nonrecurring?  
      'nonrecurring'
    else
      nil
    end    
    
  end

  def occurrence

    return @occurrence if @occurrence 
    return unless self.schedule?

    if self.yearly?
      @occurrence = self.schedule.to_hash[:rrules][0][:validations][:day_of_year][0]
    elsif self.monthly?
      @occurrence = self.schedule.to_hash[:rrules][0][:validations][:day_of_month][0]
    elsif self.weekly?
      @occurrence = self.schedule.to_hash[:rrules][0][:validations][:day][0]
    else  
      nil
    end

  end
  
  def weekly_occurrence 
    @weekly_occurrence ||= I18n.t("simple_form.arrays.weekday")[self.occurrence] if self.weekly?
  end
  
  def monthly_occurrence
    @monthly_occurrence ||= I18n.t("simple_form.arrays.day_of_month")[self.occurrence + 1] if self.monthly?
  end

  def self.period_collection
    [:weekly, :monthly]
  end

  def self.weekday_collection
    [:"0", :"1", :"2", :"3", :"4", :"5", :"6"]
  end
  
  def self.day_of_month_collection
    [:"-1", :"1"]
  end

    
  ################ ICE_CUBE SCHEDULING ########################################3





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
