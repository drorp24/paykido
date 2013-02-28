class Consumer < ActiveRecord::Base
  
  belongs_to  :payer
  has_many    :purchases
  has_many    :rules
  has_many    :allowances
  
  
      
  def under_threshold
    rule = Rule.where("consumer_id =? and property = ?", self.id, "under").first
    return 0 if !rule or rule.value.blank?
    rule.value.to_i
  end

  def over_threshold
    rule = Rule.where("consumer_id =? and property = ?", self.id, "over").first
    return 0 if !rule or rule.value.blank?
    rule.value.to_i
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
  
  def balance(given_datetime = Time.now)
    self.monetary_sum(given_datetime) - self.purchase_sum(given_datetime)
  end
    
  def allowance_rule
    Rule.allowance_rule_of(self)
  end
  
  def allowance
    Rule.allowance_of(self)
  end

  def monetary_sum(given_datetime = Time.now)

    @monetary_sum = 0
    for monetary_rule in self.rules.monetary do 
      @monetary_sum += monetary_rule.schedule.occurrences(given_datetime).count * monetary_rule.value.to_d if monetary_rule.schedule
    end
    @monetary_sum
  end

  def purchase_sum(given_datetime)

    if given_datetime
      self.purchases.approved.where("date <= ?", given_datetime).sum("amount")
    else
      self.purchases.approved.sum("amount")
    end

  end
  
  def spent 
    self.purchase_sum
  end
  
# allowance.schedule.add_recurrence_time(DateTime.new(params[:year],params[:month],params[:day]))

  def set_rules!
    Rule.set_for!(self)
  end


end