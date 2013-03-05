class Consumer < ActiveRecord::Base
  
  belongs_to  :payer
  has_many    :purchases
  has_many    :rules
  has_many    :allowances
  
  
      
  def under_threshold
    rule = Rule.under_rule_of(self)
    if rule and !rule.value.blank?
      rule.value.to_i
    else
      nil
    end
  end

  def over_threshold
    rule = Rule.over_rule_of(self)
    if rule and !rule.value.blank?
      rule.value.to_i
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
  
  def deduct!(amount)
    self.purchases_since_acd += amount
    self.save!
  end
  
  def confirm!            
    self.confirmed = true
    self.confirmed_at = Time.now
    self.save!
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
    self.monetary_sum(given_datetime) - self.purchase_sum(given_datetime)
  end
    
  def monetary_sum(given_datetime = Time.now)
    
    start_datetime = self.payer.registration_date

    @monetary_sum = 0
    for monetary_rule in self.rules.monetary do 
      @monetary_sum += monetary_rule.schedule.occurrences_between(start_datetime, given_datetime).count * monetary_rule.value.to_d if monetary_rule.schedule
    end
    @monetary_sum
  end

  def purchase_sum(given_datetime)

    start_datetime = self.payer.registration_date

    if given_datetime
      self.purchases.approved.where("date > ? and date <= ?", start_datetime, given_datetime).sum("amount")
    else
      self.purchases.approved.sum("amount")
    end

  end
  
  def spent 
    self.purchase_sum(Time.now)
  end
  
  def got
    self.monetary_sum(Time.now)
  end
  
##  Balance

  def allowance_rule
    Rule.allowance_rule_of(self)
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
  
  def allowance
    Rule.allowance_of(self)
  end

# allowance.schedule.add_recurrence_time(DateTime.new(params[:year],params[:month],params[:day]))

  def set_rules!
    Rule.set_for!(self)
  end


end