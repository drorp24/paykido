class DataController < ApplicationController
  
def locations
  
  for purchase in Purchase.all do  

    purchase.update_attributes(:location => generate_location) 
 
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
