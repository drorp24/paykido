class Payment < ActiveRecord::Base
  
  belongs_to  :purchase
  
end
