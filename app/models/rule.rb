class Rule < ActiveRecord::Base
    belongs_to :payer
    belongs_to :consumer
    
    

end
