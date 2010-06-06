class DataController < ApplicationController
  
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
 
 
 
end
