class DataController < ApplicationController
  
def update_consumer_payer_rules
  
  for consumer in Consumer.all do

    payer = consumer.payer
    unless payer
      consumer.update_attributes!(:payer_id => 102)
      payer = Payer.find(102)
    end
    
    payer_rule =  payer.most_recent_payer_rule
    unless payer_rule
      payer_rule = payer.payer_rules.create!(:allowance => 25, :rollover => false, :auto_authorize_under => 10, :auto_deny_over => 50)        
    end
    
    consumer_rule = consumer.most_recent_payer_rule
    unless consumer_rule
      allowance = (payer_rule.allowance.blank?)?25:payer_rule.allowance 
      rollover = (payer_rule.rollover.blank?)?false:payer_rule.rollover
      auto_authorize_under = (payer_rule.auto_authorize_under.blank?)?9:payer_rule.auto_authorize_under
      auto_deny_over = (payer_rule.auto_deny_over.blank?)?49:payer_rule.auto_deny_over      
      consumer_rule = consumer.payer_rules.create!(:allowance => allowance, :rollover => rollover, :auto_authorize_under => auto_authorize_under, :auto_deny_over => auto_deny_over)
    end
        
    consumer.update_attributes!(:balance => allowance) if consumer.balance.blank?

  end
  
  redirect_to :action => 'index'
  
end

def locations
  
  for purchase in Purchase.all do  

    purchase.update_attributes!(:location => generate_location) 
 
  end

end

def consumers
  
  for purchase in Purchase.all do  

    consumer = Consumer.find_by_payer_id(purchase.payer_id)
    unless consumer
      consumer = Consumer.new(:payer_id => purchase.payer_id, :billing_phone => rand.to_s.last(10))
      consumer.save!
    end
    purchase.update_attributes!(:consumer_id => consumer.id) 
    
    redirect_to :action => 'index'
 
  end
  
  
end

def generate_location
      
    r = rand
    if r < 0.33
      location = "China"
    elsif r < 0.66
      location = "Israel"
    else
      location = "US"
    end
   
end

def copy_payer_id
  
  for pr in PayerRule.all do
    pr.update_attributes!(:new_payer_id => pr.payer_id)
  end

  
end
 
 
 
end