class Category < ActiveRecord::Base
  
#  has_many :products
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_accessor :name

def initialize (name)
  @name = name
end

def sett (name)
  @name = name
end


end
