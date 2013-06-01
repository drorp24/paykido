class Consumer < ActiveRecord::Base
  
  belongs_to  :payer
  has_many    :purchases
  has_many    :rules
  has_many    :allowances
  
  
      
  def invites
    self.balance_on_acd.to_i || 0
  end
  
  def invites_increase(invites)
    self.balance_on_acd ||= 0
    self.balance_on_acd += invites.to_i
    self.save
  end

  def under_threshold
    rule = Rule.under_rule_of(self)
    if rule and !rule.amount.zero?
      rule.amount
    else
      nil
    end
  end

  def over_threshold
    rule = Rule.over_rule_of(self)
    if rule and !rule.amount.zero?
      rule.amount
    else
      nil
    end
  end

  def blacklisted?(property, value)
    Rule.set?(:consumer_id => self.id, :property => property, :value => value, :status => 'blacklisted')
  end

  def whitelisted?(property, value)
    Rule.set?(:consumer_id => self.id, :property => property, :value => value, :status => 'whitelisted')
  end
  
  def confirm!            
    self.confirmed = true
    self.confirmed_at = Time.now
    self.save!
    
    Sms.notify_consumer(self, 'confirmation', 'done')

  end
  
  def confirmed?
    self.confirmed
  end
  
  def facebook_user 
    unless @facebook_user 
      @facebook_user = Mogli::User.find(facebook_id,Mogli::Client.new(facebook_access_token, nil)) 
      @facebook_user.fetch 
    end 
    @facebook_user 
  end 
  
##  Balance

  def balance(given_datetime = Time.now)
    return nil unless self.payer.currency
    @balance ||= self.monetary_sum(given_datetime) - self.purchase_sum(given_datetime)
  end
    
  def monetary_sum(given_datetime = Time.now)
    
    return @monetary_sum if @monetary_sum

    @monetary_sum = 0
    for monetary_rule in self.rules.monetary do 
      @monetary_sum += monetary_rule.amount.amount * monetary_rule.effective_occurrences(given_datetime) if monetary_rule.schedule
    end

    @monetary_sum

  end

  def prev_allowance_sum(given_datetime = Time.now)
    
    return @allowance_sum if @allowance_sum

    @allowance_sum = 0
    for allowance_rule in self.rules.of_allowance do 
      next unless allowance_rule.stopped?
      @allowance_sum += allowance_rule.amount.amount * allowance_rule.effective_occurrences(given_datetime) if allowance_rule.schedule
    end

    @allowance_sum

  end


  def purchase_sum(given_datetime)

    return @purchase_sum if @purchase_sum

    start_datetime = self.payer.registration_date

    if given_datetime
      @purchase_sum = self.purchases.approved.where("created_at > ? and created_at <= ?", start_datetime, given_datetime).sum("amount")
    else
      @purchase_sum = self.purchases.approved.sum("amount")
    end

  end
  
  def spent 
    @spent ||= self.purchase_sum(Time.now)
  end
  
  def got
    @got ||= self.monetary_sum(Time.now)
  end
  
##  Balance

  def allowance_rule
    @allowance_rule ||= Rule.allowance_rule_of(self)
  end
  
  def allowance
    Rule.allowance_of(self)
  end
  
  def no_allowance?
    allowance_rule = self.allowance_rule
    allowance_rule.nil? || allowance_rule.initialized?
  end


  def gift_rule
    Rule.gift_rule_of(self)
  end
  
  def achievement_rule
    Rule.achievement_rule_of(self)
  end
  
  def birthday_rule
    Rule.birthday_rule_of(self)
  end
  
  def chores_rule
    Rule.chores_rule_of(self)
  end
  
  def request_rule
    Rule.request_rule_of(self)
  end
  
# allowance.schedule.add_recurrence_time(DateTime.new(params[:year],params[:month],params[:day]))

  def set_rules!(params)
    Rule.set_for!(self, params)
  end


end