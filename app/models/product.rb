require 'ruby-debug'
class Product < ActiveRecord::Base
  belongs_to  :category
  
  has_many    :items
  has_many    :retailers, :through => :items
  has_many    :purchases
  
#  validates_presence_of :title, :description, :image_url


  validates_numericality_of :price


  validate :price_must_be_at_least_a_cent


protected
  def price_must_be_at_least_a_cent
    errors.add(:price, 'should be at least 0.01') if price.nil? ||
                       price < 0.01
  end



end
