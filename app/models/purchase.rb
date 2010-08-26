require 'ruby-debug'

class Purchase < ActiveRecord::Base
#  versioned
  
  belongs_to :consumer
  belongs_to :payer
  belongs_to :retailer
  belongs_to :product
  has_one :category, :through => :product
  
  validates_presence_of :consumer_id, :payer_id, :retailer_id, :product_id, :amount, :date
  validates_numericality_of :amount
  
#  attr_accessor :authorization_date, :authorization_type
    
  def self.pending_amt(payer_id)
    self.sum(:amount, :conditions => ["payer_id = ? and authorization_type = ?", payer_id, "PendingPayer"]) 
  end
  
  def self.pending_trxs(payer_id)
    self.find_all_by_payer_id(payer_id, 
      :conditions => ["authorization_type = ?", "PendingPayer"],
      :order => "date desc")
  end
  
  def self.pending_cnt(payer_id)
    pending = self.pending_trxs(payer_id)
    counter = pending.size
    purchase_id = pending[0].id if counter == 1
    return counter, purchase_id
  end
  
  def self.pending_count(payer_id)
    self.count :conditions => ["payer_id = ? and authorization_type = ?", payer_id, "PendingPayer"]
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

  def self.retailer_sales(retailer_id)
    self.find_all_by_retailer_id(retailer_id, 
        :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id",
        :select =>      "products.title, categories.name, location, date, amount, authorized, payer_id, product_id")
  end
 
  def self.retailer_top_categories(retailer_id)
    self.sum   :amount,
               :conditions => ["retailer_id = ? and authorized = ?", retailer_id, true],
               :joins => "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id",
               :group => "categories.name",
               :order => "amount desc"
  end 

  def self.payer_purchases_by_consumers(payer_id, month)
    self.sum   :amount,
               :conditions => ["payer_id = ? and date('%m') = ?", payer_id, month],
               :joins => "inner join consumers on purchases.consumer_id = consumer.id",
               :group => "purchases.consumer_id",
               :select => ("consumer_id, consumers.name, amount")

  
  end

  def self.SAVEby_payer_retailer_and_month(payer_id, retailer_id, month)
    self.find_all_by_payer_id_and_retailer_id(payer_id, retailer_id,
               :conditions => ["authorized = ?", true],
               :group => "retailer_id",
               :select => "retailer_id, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent")  
    
  end
  
  def self.SAVEpayer_retailers_with_retailer_info_and_status_info(payer_id)
    self.find_all_by_payer_id(payer_id, 
                :joins  =>      "inner join retailers on purchases.retailer_id = retailers.id left outer join rlists on purchases.retailer_id = rlists.retailer_id and purchases.payer_id = rlists.payer_id",
                :select =>      "DISTINCT retailers.id, retailers.name, retailers.logo, rlists.status")

  end

  def self.payer_retailers_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.retailer_id",
              :joins  =>      "inner join retailers on purchases.retailer_id = retailers.id left outer join rlists on purchases.retailer_id = rlists.retailer_id and purchases.payer_id = rlists.payer_id",
              :select =>      "retailers.id, retailers.name, retailers.logo, rlists.status, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")

  end

  def self.payer_products_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.product_id",
              :joins  =>      "inner join products on purchases.product_id = products.id left outer join plists on purchases.product_id = plists.product_id and purchases.payer_id = plists.payer_id",
              :select =>      "products.id, products.title, products.logo, plists.status, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")

  end

  def self.payer_categories_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "categories.id",
              :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id left outer join clists on categories.id = clists.category_id and purchases.payer_id = clists.payer_id",
              :select =>      "categories.id, categories.name, categories.logo, clists.status, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")

  end

  
  def self.payer_pendings_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ? and authorization_type = ?", false, "PendingPayer"],
               :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id inner join consumers on purchases.consumer_id = consumers.id inner join retailers on purchases.retailer_id = retailers.id",
               :select =>      "purchases.id, consumers.name as consumer_name, retailers.name as retailer_name, retailers.logo, products.title as product_title, amount, date, authorization_type, authentication_type, authentication_date, location",
               :order =>       "date desc")

  end

  def self.payer_purchases_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
               :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id inner join consumers on purchases.consumer_id = consumers.id inner join retailers on purchases.retailer_id = retailers.id",
              :select =>      "purchases.id, consumers.name as consumer_name, retailers.name as retailer_name, retailers.logo, products.title as product_title, amount, date, authentication_type, authentication_date, authorized, authorization_type, authorization_date, location")

  end
  
  def self.payer_purchases_all_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
               :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id inner join consumers on purchases.consumer_id = consumers.id inner join retailers on purchases.retailer_id = retailers.id",
               :select =>      "purchases.id, consumers.name as consumer_name, retailers.name as retailer_name, retailers.logo as retailer_logo, products.title as product_title, categories.name as category_name, amount, date, authentication_type, authentication_date, authorized, authorization_type, authorization_date, location",
               :order =>       "date desc")

  end
  def self.SAVEby_payer_retailer_and_month(payer_id, retailer_id, month)
    self.sum   :amount,
               :conditions => ["payer_id =? and retailer_id = ? and authorized = ? and strftime('%m', date) = ?", payer_id, retailer_id, true, month],
               :group => "retailer_id",
               :select => "amount, count(*) as purchase_count, max(date) as most_recent"  
    
  end
   
end
