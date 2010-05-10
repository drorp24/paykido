class Purchase < ActiveRecord::Base
  versioned
  
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
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "PendingPayer"]).size
  end
  
  def self.never_authorized(payer_id)
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "NeverAuthorized"],:select => "retailer_id, product_id, updated_at")
  end

  def self.always_authorized(payer_id)
    self.find_all_by_payer_id(payer_id, :conditions => ["authorization_type = ?", "AlwaysAuthorized"],:select => "retailer_id, product_id, updated_at")
  end
 
  def self.by_product_id(payer_id, product_id)
    self.find_all_by_product_id(product_id, :conditions => ["payer_id = ?", payer_id],:select => "id, retailer_id, product_id, amount, date")
  end
  
  def self.by_retailer_id(payer_id, retailer_id)
    self.find_all_by_retailer_id(retailer_id, :conditions => ["payer_id = ?", payer_id],:select => "id, retailer_id, product_id, amount, date")
  end
    
  def self.payer_top_products(payer_id, limit)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorization_date != '' and authorization_type not in ('PendingPayer', 'NotAuthorized', 'NeverAuthorized')", payer_id], 
               :group => "product_id" ,
               :order => "amount desc",
               :limit => limit

  end

   def self.payer_top_retailers(payer_id, limit)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorization_date != '' and authorization_type not in ('PendingPayer', 'NotAuthorized', 'NeverAuthorized')", payer_id], 
               :group => "retailer_id" ,
               :order => "amount desc", 
               :limit => limit
  end
  
  def self.payer_top_categories(payer_id)
    self.sum   :amount,
               :conditions => ["payer_id = ? and authorization_date != '' and authorization_type not in ('PendingPayer', 'NotAuthorized', 'NeverAuthorized')", payer_id],
               :joins => "inner join products on purchases.product_id = products.id",
               :group => "category_id",
               :order => "amount desc"
  end
  
  
  
  def self.full_list(payer_id)
    self.find_all_by_payer_id(payer_id,
              :conditions => ["authorization_date != '' and authorization_type not in ('PendingPayer', 'NotAuthorized', 'NeverAuthorized')"],
              :select => "id, retailer_id, product_id, amount, date, authorization_date")
  end
  
  def self.revert
    self.each do |p| 
      p.revert_to(60.seconds.ago)
    end
  end

end
