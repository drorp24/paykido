class Consumer < ActiveRecord::Base
  
  belongs_to  :payer
  has_many    :purchases
  has_many    :rules
  has_many    :allowances
      
  after_initialize :init
  def init
      self.allowance  ||= 10          
      self.allowance_period ||= 'Weekly'
      self.allowance_change_date ||= Time.now
      self.balance_on_acd ||= 0
      self.purchases_since_acd ||= 0
      self.auto_authorize_under ||= 5
      self.auto_deny_over ||= 35
  end


  def blacklist!(property, value)
    rule = Rule.set!(self.payer_id, self.id, property, value, 'blacklist')
  end
  
  def blacklisted?(property, value)
    Rule.set?(:payer_id => self.payer_id, :consumer_id => self.id, :property => property, :value => value, :status => 'blacklisted')
  end

  def whitelist!(property, value)
    rule = Rule.set!(self.payer_id, self.id, property, value, 'whitelist')
  end
  
  def whitelisted?(property, value)
    Rule.set?(:payer_id => self.payer_id, :consumer_id => self.id, :property => property, :value => value, :status => 'whitelisted')
  end
  
  def reset!(property, value)
    rule = Rule.set!(self.payer_id, self.id, property, value, '')
  end

  
  def allowance_day_of_week
    self.allowance_every || 0
  end
  
  def allowance_day_of_week=(value)
    self.allowance_every = value
  end
  
  def self.allowance_days_of_month
    [["1st of month", 1]]
  end

  def next_allowance_date

    if self.allowance_period == 'Weekly'
      @next_allowance_date = Date.today.beginning_of_week.advance(:days => self.allowance_day_of_week.to_i || 0)
      @next_allowance_date = @next_allowance_date.advance(:weeks => 1) if @next_allowance_date < Date.today
    elsif self.allowance_period == 'Monthly'
      @next_allowance_date = Time.now.next_month.change(:day => self.allowance_every.to_i || 0)
    else
      @next_allowance_date = nil
    end 
    @next_allowance_date   
  end
 
  def balance

    self.balance_on_acd        ||= 0
    self.allowance             ||= 0
    self.purchases_since_acd   ||= 0
    self.allowance_change_date ||= self.created_at

    @balance = self.balance_on_acd + self.periods_since_acd *  self.allowance - self.purchases_since_acd
 
  end

  def periods_since_acd                     # ToDo: correct calculation by allowance_day_of_week/month            
    if allowance_period == 'Weekly'         
      (Time.now.strftime("%Y").to_i * 52 + Time.now.strftime("%W").to_i) - (allowance_change_date.strftime("%Y").to_i * 52 + allowance_change_date.strftime("%W").to_i) + 1
    elsif allowance_period == 'Monthly'
      (Time.now.strftime("%Y").to_i * 12 + Time.now.strftime("%m").to_i) - (allowance_change_date.strftime("%Y").to_i * 12 + allowance_change_date.strftime("%m").to_i) + 1
    else
      nil 
    end           
  end
    
  def allowance_change!(params)

      return if params[:allowance] == self.allowance and params[:allowance_period] == self.allowance_period    
          
      self.allowance =            params[:allowance]
      self.allowance_period =     params[:allowance_period]
      self.allowance_every =     (params[:allowance_period] == 'Weekly') ?0 :1     #ToDo: have the default day-of-week locale-dependent (yml)
      self.balance_on_acd =       self.balance
      self.purchases_since_acd =  0
      self.allowance_change_date= Time.now
      self.save!

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
  
  def allowance_display
    
  end
  def allowance_display=(value)
    
  end
  
  def auto_deny_over_display
    
  end
  def auto_deny_over_display=(value)
    
  end
  
  def auto_authorize_under_display
    
  end
  def auto_authorize_under_display=(value)
    
  end

  
end