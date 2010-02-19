class Billing < ActiveRecord::Base
  
 
  validates_presence_of :type
  validates_uniqueness_of :type
  
  attr_accessor :type

def initialize (type)
  @type = type
end

def sett (type)
  @type = type
end

end

