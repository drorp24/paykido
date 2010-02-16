class Category < ActiveRecord::Base
  
  has_many :products
  
  validates_presence_of :category
  validates_uniqueness_of :category
end
