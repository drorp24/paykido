class Billing < ActiveRecord::Base
   
 
  validates_presence_of :method
  validates_uniqueness_of :method
  
  attr_accessor :method

end