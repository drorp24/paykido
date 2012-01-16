include ActionView::Helpers::NumberHelper
class Product < ActiveRecord::Base
  belongs_to  :category
  
  has_many    :items
  has_many    :retailers, :through => :items
  has_many    :purchases
     
  has_many :plists
  has_many :payers, :through => :plists    # to be used for queries such as "who blacklists me" (not likely)

  
#  validates_presence_of :title, :description, :image_url


  validates_numericality_of :price


  validate :price_must_be_at_least_a_cent


  def blacklist!(payer_id, consumer_id)
    plist = Plist.find_or_initialize_by_product_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    plist.update_attributes!(:rule => 'blacklisted')
  end
  
  def blacklisted?(payer_id, consumer_id)
    plist.where(:product_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'blacklisted').exists?
  end

  def whitelist!(payer_id, consumer_id)
    plist = Plist.find_or_initialize_by_product_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    plist.update_attributes!(:rule => 'whitelisted')
  end
  
  def whitelisted?(payer_id, consumer_id)
    plist.where(:product_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'whitelisted').exists?
  end

  
  def self.find_product_options(retailer_id)
    
    Item.find_all_by_retailer_id(retailer_id,
         :joins  =>  "inner join products on items.product_id = products.id",
         :select =>  "products.id, products.title, products.price",
         :order => "products.price DESC").map {|product| [product.title + " " + number_to_currency(product.price), product.id]}
    
  end
  

protected
  def price_must_be_at_least_a_cent
    errors.add(:price, 'should be at least 0.01') if price.nil? ||
                       price < 0.01
  end



end
