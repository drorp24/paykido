class Purchase < ActiveRecord::Base
  belongs_to :payer
  belongs_to :retailer
  belongs_to :product
 
  
  validates_presence_of :payer_id, :retailer_id, :product_id, :amount, :date
  validates_numericality_of :amount
  
#  attr_accessor :authorization_date, :authorization_type
  
  def self.pending_amt(payer_id)
    self.sum(:amount, :conditions => ["payer_id = ? and authorization_type = ?", payer_id, "PendingPayer"]) 
  end
  
  def self.pending_trx(payer_id)
    self.find_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "PendingPayer"])
  end
  
  def self.never_authorized(payer_id)
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "NeverAuthorized"],:select => "retailer_id, product_id, updated_at")
  end

  def self.always_authorized(payer_id)
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "AlwaysAuthorized"],:select => "retailer_id, product_id, updated_at")
  end
 
  def self.by_product_title(product_title)
    product = Product.find_by_title(product_title)
    self.find_all_by_product_id(product.id,:select => "id, retailer_id, product_id, amount, date")
  end
  
  def self.by_retailer_name(retailer_name)
    retailer = Retailer.find_by_name(retailer_name)
    self.find_all_by_retailer_id(retailer.id,:select => "id, retailer_id, product_id, amount, date")
  end

end
