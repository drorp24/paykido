require 'ruby-debug'

class Purchase < ActiveRecord::Base
#  versioned
  
  belongs_to :payer
  belongs_to :retailer
  belongs_to :product
  
  validates_presence_of :payer_id, :retailer_id, :product_id, :amount, :date
  validates_numericality_of :amount
  
#  attr_accessor :authorization_date, :authorization_type
    
  def self.pending_amt(payer_id)
    self.sum(:amount, :conditions => ["payer_id = ? and authorization_type = ?", payer_id, "PendingPayer"]) 
  end
  
  def self.pending_trxs(payer_id)
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "PendingPayer"])
  end
  
  def self.pending_cnt(payer_id)
    pending = self.pending_trxs(payer_id)
    counter = pending.size
    purchase_id = pending[0].id if counter == 1
    return counter, purchase_id
  end
  
  def self.by_product_id(payer_id, product_id)
    self.find_all_by_product_id(product_id, 
              :conditions => ["payer_id = ? and authorized = ?", payer_id, true],
              :select => "id, retailer_id, product_id, amount, date, authorized")
  end
  
  def self.by_retailer_id(payer_id, retailer_id)
    self.find_all_by_retailer_id(retailer_id, 
              :conditions => ["payer_id = ? and authorized = ?", payer_id, true],
              :select => "id, retailer_id, product_id, amount, date, authorized")
  end
  
  def self.full_list(payer_id)
    self.find_all_by_payer_id(payer_id,
              :select => "id, retailer_id, product_id, amount, date, authorized")
  end
  
    
  def self.payer_top_products(payer_id, limit)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorized = ?", payer_id, true], 
               :group => "product_id" ,
               :order => "amount desc",
               :limit => limit

  end

   def self.payer_top_retailers(payer_id, limit)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorized = ?", payer_id, true], 
               :group => "retailer_id" ,
               :order => "amount desc", 
               :limit => limit
  end
  
  def self.payer_top_categories(payer_id)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorized = ?", payer_id, true],
               :joins => "inner join products on purchases.product_id = products.id",
               :group => "category_id",
               :order => "amount desc"
  end
  
  def self.payer_retailers(payer_id)
    self.find_all_by_payer_id(payer_id, :select => "DISTINCT retailer_id")
  end

  def self.payer_products(payer_id)
    self.find_all_by_payer_id(payer_id, :select => "DISTINCT product_id")
  end
  
  def self.payer_categories(payer_id)
    self.find_all_by_payer_id(payer_id, 
        :joins  => "inner join products on purchases.product_id = products.id",
        :group  => "category_id",
        :select => "DISTINCT category_id")
  end
 

  
  
end
