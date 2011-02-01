class DataController < ApplicationController
  
def set_policy
  
  current = Current.find(1)
  if current
    current.update_attributes!(params[:current])     
  end
  
end

def delete_consumer_by_id
    
  
  Purchase.delete_all(["consumer_id = ?", params[:consumer][:id]]) 
  
  Consumer.delete(params[:consumer][:id])

  redirect_to :action => 'index'
  
end


def delete_consumer
  
  consumer = Consumer.find_by_billing_phone(params[:consumer][:billing_phone])
  Purchase.delete_all(["consumer_id = ?", consumer.id]) 
  
  Consumer.delete(consumer.id)

  redirect_to :action => 'index'
  
end


def populate_retailers
  
  i = 1
  for purchase in Purchase.find_all_by_payer_id(params[:purchase][:payer_id]) do 
  
    purchase.retailer_id = i    
    purchase.save!
    i += 1
    i = 1 if i == 10
    
  end
  
  redirect_to :action => 'index'
  
end

def update_purchase_dates
  
  for purchase in Purchase.find_all_by_payer_id(params[:purchase][:payer_id]) do 
    purchase.date = purchase.date.change(:month => params[:purchase][:month].to_i)
    purchase.save!
  end
  
  redirect_to :action => 'index'
  
end


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
