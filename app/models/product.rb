require 'ruby-debug'
class Product < ActiveRecord::Base
  belongs_to  :category
  
  has_many    :items
  has_many    :retailers, :through => :items
  has_many    :purchases
  
#  validates_presence_of :title, :description, :image_url


  validates_numericality_of :price


  validate :price_must_be_at_least_a_cent



#  validates_format_of :image_url,
#                      :with    => %r{\.(gif|jpg|png)$}i,
#                      :message => 'must be a URL for GIF, JPG ' +
#                                  'or PNG image.'

  def quantity
    purchases.sum(:amount)
  end

  def self.top(num)
 
    products = {}
    all.each do |product|
      products[product.title] = product.quantity
    end
    products.sort{|a,b| b[1]<=>a[1]}
  
  end
  
  def self.find_products_for_sale
    find(:all, :order => "title")
  end



protected
  def price_must_be_at_least_a_cent
    errors.add(:price, 'should be at least 0.01') if price.nil? ||
                       price < 0.01
  end



end
