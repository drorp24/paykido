class Retailer < ActiveRecord::Base
  validates_presence_of :name, :category_id
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :payers, :through => :purchases
end
