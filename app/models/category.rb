class Category < ActiveRecord::Base
  validates_presence_of :category
  validates_uniqueness_of :category
end
