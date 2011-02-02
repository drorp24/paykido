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


  def plist(payer_id)
    
    Plist.find_or_initialize_by_product_id_and_payer_id(self.id, payer_id)
    
  end
  
  def status(payer_id)

    plist(payer_id).status
    
  end
  
  def update(payer_id, status)
    
    plist(payer_id).update_attributes!(:status => status)
    
  end
  
  
  def is_blacklisted(payer_id)
    
    status(payer_id) == "blacklisted" 
    
  end

  def is_whitelisted(payer_id)
    
    status == "whitelisted" 
 
  end

  def blacklist(payer_id)
    
    update(payer_id, "blacklisted")
    
  end
 
  def whitelist(payer_id)
    
   update(payer_id, "whitelisted")
    
  end
  
  def self.find_product_options(retailer_id)
    
    Item.find_all_by_retailer_id(retailer_id,
         :joins  =>  ["inner join products on items.product_id = ?", 1],
         :select =>  "products.id, products.title, products.price",
         :order => "products.price DESC").map {|product| [product.title + " " + number_to_currency(product.price), product.id]}
    
  end
  

protected
  def price_must_be_at_least_a_cent
    errors.add(:price, 'should be at least 0.01') if price.nil? ||
                       price < 0.01
  end



end
