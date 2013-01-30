class Rule < ActiveRecord::Base
  include IceCube
  
  belongs_to  :consumer

  WEEKDAY_NAMES =       I18n.t "time.day_names_array"
  MONTHLY_RECURRENCES = I18n.t "time.monthly_recurrences"
  PERIODS =             I18n.t "time.periods"

  def self.weekly_recurrence
    WEEKDAY_NAMES
  end
  
  def self.monthly_recurrence
    MONTHLY_RECURRENCES
  end

  def self.periods
    PERIODS
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
      allowance_rule = applicable_rules.first
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
  
  def stopped?
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

  def schedule?
    self.schedule.recurrence_rules.any? || self.schedule.recurrence_times.any? if self.schedule
  end

  def period

    return @period if @period 

    if self.schedule?
      @period = self.schedule.to_hash[:rrules][0][:rule_type] == "IceCube::WeeklyRule" ? 'Weekly' : 'Monthly'
    else
      @period = I18n.t "time.Weekly" 
    end 

  end
  
  def period=(prd)
    @period = prd
  end

  def occurrence_day
 
    return @occurrence_day if @occurrence_day
    return nil unless self.schedule?
 
    if self.period == 'Weekly'
      @occurrence_day = self.schedule.to_hash[:rrules][0][:validations][:day][0]
    else 
      @occurrence_day = self.schedule.to_hash[:rrules][0][:validations][:day_of_month][0]
    end
 
  end

  def weekly_occurrence 
    @weekly_occurrence = WEEKDAY_NAMES[self.occurrence_day] if self.schedule? and self.period == "Weekly"
  end

  def weekly_occurrence=(ocr)

    return if ocr.blank?
    occurrence = WEEKDAY_NAMES.index(ocr)
    schedule = IceCube::Schedule.new(Time.now) 
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(occurrence)
    self.schedule = schedule
    
  end
    
  def monthly_occurrence
    @monthly_occurrence = MONTHLY_RECURRENCES[self.occurrence_day] if self.schedule? and self.period == "Monthly"
  end

  def monthly_occurrence=(ocr)

    return if ocr.blank?
    occurrence = MONTHLY_RECURRENCES.index(ocr) == 0 ? 1 : -1
    schedule = IceCube::Schedule.new(Time.now) 
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(occurrence)
    self.schedule = schedule
    
  end
  
=begin
  def occurrence

    return @occurrence if @occurrence 
    
    if self.schedule?
      @occurrence = self.period == "Weekly" ? WEEKDAY_NAMES[self.occurrence_day]  : self.occurrence_day 
    else
      @occurrence = ""
    end
  end

  
  def occurrence=(ocr)

    return nil unless @period

    # infer period from ocr in case "occurrence=" is evaluated before "period="
    if (@period == 'Weekly' || WEEKDAY_NAMES.include?(ocr)) && !(MONTHLY_RECURRENCES.include?(ocr))      
      self.weekly_occurrence = ocr      
    else
      self.monthly_occurrence = ocr      
    end
    
    @occurrence = ocr

  end
=end
  
    
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
