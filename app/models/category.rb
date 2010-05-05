class Category < ActiveRecord::Base
  
  has_many :products
  has_many :purchases, :through => :products
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
#  attr_accessor :name
  
 
end