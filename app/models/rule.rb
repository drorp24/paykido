class Rule < ActiveRecord::Base
  include IceCube

  belongs_to  :consumer

  after_initialize :init
  def init

    if    self.property == 'allowance' or self.property == 'gift' or  self.property == 'birthday' or  self.property == 'chores'or  self.property == 'bachievement' or  self.property == 'request'   
          self.category = 'how much'
    elsif self.property == 'retailer' or  self.property == 'esrb_rating' or self.property == 'pegi_rating' or self.property == 'title' or self.property == 'category'   
          self.category = 'what'
    elsif self.property == 'time'
          self.category = 'when'
    elsif self.property == 'location'
          self.category = 'where'
    elsif self.property == 'over' or  self.property == 'under' 
          self.category = 'thresholds'
    else
          self.category = 'no matching category'
    end

  end
  
  def initialize_rule
    self.update_attributes!(:value => nil)
  end
  
  def remove
    if self.category == 'thresholds'
      self.initialize_rule
    else
      self.destroy
    end
  end

  def supported?
      self.property == 'allowance' or self.property == 'gift' or  self.property == 'birthday' or  self.property == 'chores'or  self.property == 'bachievement' or self.property == 'retailer' or  self.property == 'esrb_rating' or self.property == 'pegi_rating' or self.property == 'category' or self.property == 'title' or self.property == 'under' or self.property == 'over'
  end

  def self.whitelist_rate(property, value)
    return @rate if @rate
    whitelisting_payers_count = self.joins(:consumer).where("property = ? and value = ? and status = ?", property, value, "whitelisted").group('payer_id').count.count                                
    payers_count = Payer.count
    @rate = (whitelisting_payers_count.to_f / payers_count.to_f) * 100
  end

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

  def self.create_new!(params, id)

    if !params[:previous_rule_id].blank? 
      expired_rule = self.find(params[:previous_rule_id])
      expired_rule.expire
    end

    if params[:period]
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
    end

    unless id
      rule = self.new(params.except(:period, :weekly_occurrence, :monthly_occurrence))
    else
      rule = self.find(id)
      rule.update_attributes(params.except(:period, :weekly_occurrence, :monthly_occurrence))
    end  
    rule.schedule = schedule if params[:period]
    rule.save   
    rule
    
  end

  # Dummy property. Lives between 'new' and 'create'
  def previous_rule_id
    @previous_rule_id
  end
  
  def previous_rule_id=(rule_id)
    @previous_rule_id = rule_id
  end
  
  def note
    
  end
  
  def note=(note)
    
  end

  ####  Change if needed      ####
  scope :monetary,    where("category = ?", "how much")
  scope :thresholds,  where("category = ?", "thresholds")
  scope :what,        where("category = ? ", "what")
  scope :time,        where("category = ?", "when")
  scope :location,    where("category = ?", "where")
  
  scope :of_allowance,   where("property = ?", "allowance")
  
  def initialized?
    self.value.blank? or self.value == '0' or self.status == 'reset'
  end

  def monetary?
    self.category == "how much"
  end 
  
  def what?
    self.category == "what" 
  end

  def thresholds?
    self.category == "thresholds"
  end 
 
  def allowance?
    self.property == "allowance"
  end
  
  def over?
    self.property == 'over'
  end
  
  def under?
    self.property == 'under'
  end
  
  def singular?
    self.allowance?
  end


  def self.allowance
    schedule = IceCube::Schedule.new
    {:property => 'allowance', :category => "how much", :schedule => schedule, :value => nil}
  end
  def self.gift
    {:property => 'gift', :category => "how much"}
#   {:property => 'gift', :category => "how much", :value => "10", :date => Time.now, :donator => "Paykido", :occasion => "Welcome Gift"}
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
  def self.achievement
    {:property => 'bachievement', :category => "how much"}
  end  
  def self.retailer(retailer)
    {:property => 'retailer', :category => "what", :value => retailer, :status => 'reset'}
  end  
  def self.title(title)
    {:property => 'title', :category => "what", :value => title, :status => 'reset'}
  end  
  def self.pegi_rating(pegi_rating)
    {:property => 'pegi_rating', :category => "what", :value => pegi_rating, :status => 'reset'}
  end  
  def self.esrb_rating(esrb_rating)
    {:property => 'esrb_rating', :category => "what", :value => esrb_rating, :status => 'reset'}
  end  
  def self.category(category)
    {:property => 'category', :category => "what", :value => category, :status => 'reset'}
  end  
  def self.time1
    {:property => 'time', :category => "when"}
  end  
  def self.location1
    {:property => 'location', :category => "where"}
  end  
  def self.over
    {:property => 'over', :category => "thresholds"}
  end  
  def self.under
    {:property => 'under', :category => "thresholds"}
  end  

  def self.set_for!(consumer, params)
    consumer.rules.create!(self.allowance)
    consumer.rules.create!(self.gift)
    consumer.rules.create!(self.birthday)
    consumer.rules.create!(self.chores)
    consumer.rules.create!(self.request)
    consumer.rules.create!(self.achievement)
    consumer.rules.create!(self.retailer(params[:merchant]))
    consumer.rules.create!(self.title(params[:app]))
    consumer.rules.create!(self.category(Title.category(params[:app])))
#    consumer.rules.create!(self.pegi_rating(Title.pegi_rating(params[:app])))     # simply to not create too much template rules
#    consumer.rules.create!(self.esrb_rating(Title.esrb_rating(params[:app])))
    consumer.rules.create!(self.time1)
    consumer.rules.create!(self.location1)
    consumer.rules.create!(self.over)
    consumer.rules.create!(self.under)
  end

  ####  Change if needed      ####  

  def self.allowance_rule_of(consumer)
    self.rule_of(consumer, 'allowance')
  end
  
  def self.gift_rule_of(consumer)
    self.rule_of(consumer, 'gift')
  end

  def self.achievement_rule_of(consumer)
    self.rule_of(consumer, 'bachievement')
  end

  def self.birthday_rule_of(consumer)
    self.rule_of(consumer, 'birthday')
  end

  def self.chores_rule_of(consumer)
    self.rule_of(consumer, 'chores')
  end

  def self.request_rule_of(consumer)
    self.rule_of(consumer, 'request')
  end

  def self.rule_of(consumer, property)
    applicable_rules = self.where("consumer_id = ? and property = ?", consumer.id, property)
    if applicable_rules.any?
      applicable_rules.last          # ToDo: think!
    else
      nil
    end
  end
    

  # ToDo: DELETE. Use only the rule object, dont create a special hash, just reducndant.
  def self.allowance_of(consumer)

    @allowance = 
    { :amount => 0, 
      :period => "",
      :weekly => false,
      :monthly => false,
      :weekly_occurrence => nil,
      :monthly_occurrence => nil,
      :next_occurrence => nil,
      :start_date => nil,
      :number_of_grants => 0,
      :so_far_accumulated => 0,
      :prev_allowance_acc => 0 }

    unless consumer.payer.rules_require_registration

        allowance_rule = allowance_rule_of(consumer)          
        prev_allowance_sum = consumer.prev_allowance_sum.to_i
  
        unless allowance_rule.expired?
          @allowance = 
          { :amount => val = allowance_rule.value.to_i, 
            :period => allowance_rule.period,
            :weekly => allowance_rule.weekly?,
            :monthly => allowance_rule.monthly?,
            :weekly_occurrence => allowance_rule.weekly_occurrence,
            :monthly_occurrence => allowance_rule.monthly_occurrence,
            :next_occurrence => allowance_rule.schedule.next_occurrence,
            :start_date => allowance_rule.schedule.start_date,
            :number_of_grants => grants = allowance_rule.effective_occurrences,
            :so_far_accumulated => grants * val,
            :prev_allowance_acc => prev_allowance_sum }
        else
          @allowance[:prev_allowance_acc] = prev_allowance_sum 
        end
      
    end      

    @allowance
    
  end
  
  def self.under_rule_of(consumer)
    self.where('consumer_id = ? and property = ?', consumer.id, "under").first
  end
  
  def self.over_rule_of(consumer)
    self.where('consumer_id = ? and property = ?', consumer.id, "over").first
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
    self.schedule and self.schedule.recurrence_rules.any?
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
  
  def expired?
    self.recurring? and !self.schedule.end_time.nil?
  end
  
  def stopped?        # same thing, only does fewer cheks for allowance only
    !self.schedule.end_time.nil?
  end
  
  def nonrecurring?
    !self.recurring? and self.schedule and !self.schedule.recurrence_rules.any? and self.schedule.recurrence_times[0]
  end
  
  def date
    self.nonrecurring? and self.schedule.recurrence_times[0]
  end
  
  def date=(newdate)

    if newdate.is_a? String
      newdate = newdate.to_datetime.end_of_day.to_time_in_current_zone
    elsif newdate.is_a? Date
      newdate = newdate.end_of_day.to_time_in_current_zone 
    end
    newdate = Time.zone.now if newdate < Time.zone.now    # Otherwise, if rule was set to today, it will get midnight time and won't be effective i ncase parent just registered
    schedule = IceCube::Schedule.new(newdate)
    schedule.add_recurrence_time(newdate)
    self.schedule = schedule

  end
  
  def passed?
    self.date < Time.now
  end    

  def expire
    return unless self.recurring?
    new_schedule = self.schedule 
    new_schedule.end_time = Time.now
    self.schedule = new_schedule
    self.save
  end

  def restart
    return unless self.expired?
    new_rule = self.dup
    new_schedule = self.schedule.to_hash.except(:end_time)
    new_schedule[:start_date] = Time.now
    new_rule.schedule = new_schedule
    new_rule.save
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
  
  def effective_occurrences(given_datetime = Time.now)
    return 0 unless self.consumer.payer.registered?
    return 0 unless self.schedule
    start_datetime = self.consumer.payer.registration_date
    if start_datetime
      self.schedule.occurrences_between(start_datetime, given_datetime).count
    else
      0
    end
  end


#  def update_relevant_attributes(params)
    
#    if params[:period] == 'Monthly'
#      self.update_attributes(
#        :value => params[:value],
#        :period => params[:period],
#        :monthly_occurrence => params[:monthly_occurrence]
#        )
#    elsif params[:period] == 'Weekly'
#      self.update_attributes(
#        :value => params[:value],
#        :period => params[:period],
#        :weekly_occurrence => params[:weekly_occurrence]
#        )
#    else
#       self.update_attributes(params)         
#    end
    
#  end
   
  ################ ICE_CUBE SCHEDULING ########################################3





  def self.set!(params) 

#   rule = self.where(params.except[:authenticity_token]).first_or_initialize    # as of Rails 3.2.1
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
