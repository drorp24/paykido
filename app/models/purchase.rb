class Purchase < ActiveRecord::Base
  serialize :properties

#  versioned
  
  belongs_to :consumer
  belongs_to :payer
  belongs_to :retailer
#  belongs_to :product
#  belongs_to :title
  has_one :category
  
#  validates_presence_of :consumer_id, :payer_id, :retailer_id, :product_id, :amount, :date
#  validates_numericality_of :amount
  
#  attr_accessor :authorization_date, :authorization_type

  def self.create_new!(payer, consumer, retailer, title, product, price, params)
    
    retailer_id = Retailer.find_or_create_by_name(retailer).id
    title_rec =   Title.find_or_create_by_name(title)
    product_id =  Product.find_or_create_by_title(product).id   # bck compat.
    
    self.create!(:payer_id => payer.id,
                 :consumer_id => consumer.id,
                 :retailer_id => retailer_id,
                 :product_id => product_id,             # not needed anymore - left for bck compat. (/service)
                 :category_id => 3,                     # not needed anymore - left for bck compat. (/service) 
                 :product => product,
                 :title => title,                 
                 :amount => price,
                 :date => Time.now,
                 :properties => {
                    "retailer" =>  retailer,
                    "title" =>     title,
                    "category" =>     title_rec.category,                                   
                    "esrb_rating" =>  title_rec.esrb_rating,
                    "pegi_rating" =>  title_rec.pegi_rating
                  },
                  :params => {
                    "merchant" => params[:merchant],
                    "app" => params[:app],
                    "product" => params[:product],
                    "amount" => params[:amount],
                    "currency" => params[:currency],
                    "userid" => params[:userid],
                    "mode" => params[:mode],
                    "tid" => params[:tid],
                    "hash" => params[:hash]
                  }
                  )
  end


  def authorize!
       
    self.authorized = false

    self.properties.each {|property,value| 
      if self.consumer.blacklisted?(property, value)  
        self.authorization_property = property
        self.authorization_value = value
        self.authorization_type = "Blacklisted"
        self.authorization_date = Time.now
        self.save!
        return
      end
    }
          
    if self.consumer.balance <= 0
      self.authorization_property = "Balance"
      self.authorization_value = self.consumer.balance
      self.authorization_type = "Unauthorized"  
    elsif self.consumer.balance < self.amount
      self.authorization_property = "Balance"
      self.authorization_value = self.consumer.balance
      self.authorization_type = "Too Low"
    elsif self.amount <= self.consumer.auto_authorize_under
      self.authorization_property = "Amount"
      self.authorization_value = self.amount
      self.authorization_type = "Under Threshold"
      self.authorized = true
    elsif self.amount > self.consumer.auto_deny_over
      self.authorization_property = "Amount"
      self.authorization_value = self.amount
      self.authorization_type = "Too High"
      
    else
      
      self.properties.each {|property,value| 
        if self.consumer.whitelisted?(property, value)  
          self.authorization_property = property
          self.authorization_value = value
          self.authorization_type = "Whitelisted"
          self.authorized = true
          self.authorization_date = Time.now
          self.save!
          return
        end
    }

      self.require_manual_approval
    end
    
    self.authorization_date = Time.now
    self.save!
    
  end  

  def require_manual_approval
    self.authorization_type = "PendingPayer"
  end

  def require_manual_approval!
    self.update_attributes!(
      :authorization_type => "PendingPayer")
  end
  
  def requires_manual_approval?
    self.authorization_type == "PendingPayer"
  end

  def manually_handled?
    self.authorization_type == "ManuallyAuthorized" or 
    self.authorization_type == "Unauthorized" or
    self.authorization_type ==  "PendingPayer"
  end
    
  def manually_authorize!
    self.update_attributes!(
      :authorized => true,
      :authorization_type => "ManuallyAuthorized",
      :authorization_date => Time.now) 
  end
  
  def manually_authorized?
    self.authorization_type == "ManuallyAuthorized"
  end
  
  def manually_decline!
    self.update_attributes!(
      :authorized => false,
      :authorization_type => "Unauthorized",
      :authorization_date => Time.now) 
  end
  
  def manually_declined?
    self.authorization_type == "Unauthorized"
  end
  
  def automatically_authorized?
    self.authorized and !self.manually_handled?
  end
  
  def automatically_declined?
    !self.authorized and self.authorization_type and !self.manually_handled?
  end
  
  def account_for!
    
    amount = self.amount
    
    self.consumer.record!(amount)
    self.retailer.record!(amount)    
   
  end

  def self.pending_amt(payer_id)
    self.sum(:amount, :conditions => ["payer_id = ? and authorization_type = ?", payer_id, "PendingPayer"]) 
  end
  
  def self.pending_trxs(payer_id)
    self.find_all_by_payer_id(payer_id, 
      :conditions => ["authorization_type = ? and consumer_id is not ?", "PendingPayer", nil ],
      :order => "date desc")
  end
  
  def self.pending_cnt(payer_id)
    pending = self.pending_trxs(payer_id)
    counter = pending.size
    purchase_id = pending[0].id if counter == 1
    return counter, purchase_id
  end
  
  def self.pending_count(payer_id)
    self.count :conditions => ["payer_id = ? and authorization_type = ? and consumer_id is not ?", payer_id, "PendingPayer", nil]
  end
  
  def self.full_list(payer_id)
    self.find_all_by_payer_id(payer_id,
              :select => "id, retailer_id, product_id, amount, date, authorized")
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
        :select =>      "products.title, categories.name, date, amount, authorized, authorization_type, payer_id, product_id")
  end
 
  def self.payer_purchases_by_consumers(payer_id, month)
    self.sum   :amount,
               :conditions => ["payer_id = ? and date('%m') = ?", payer_id, month],
               :joins => "inner join consumers on purchases.consumer_id = consumer.id",
               :group => "purchases.consumer_id",
               :select => ("consumer_id, consumers.name, amount")

  
  end

  def self.payer_consumers_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.consumer_id, consumers.id, consumers.name, consumers.balance, consumers.pic",
              :joins  =>      "inner join consumers on purchases.consumer_id = consumers.id",
              :select =>      "consumers.id, name, balance, pic, sum(amount) as sum_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "sum_amount desc")
              

  end

  def self.payer_retailers_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.retailer_id, retailers.id, retailers.name, retailers.logo",
              :joins  =>      "inner join retailers on purchases.retailer_id = retailers.id",
              :select =>      "retailers.id, retailers.name, retailers.logo, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")
              

  end

  def self.payer_products_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.product_id, products.id, products.title, products.logo",
              :joins  =>      "inner join products on purchases.product_id = products.id",
              :select =>      "products.id, products.title, products.logo, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")

  end

  def self.payer_categories_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
              :conditions => ["authorized = ?", true],
              :group =>       "purchases.category_id, categories.id, categories.name, categories.logo",
              :joins  =>      "inner join categories on purchases.category_id = categories.id",
              :select =>      "categories.id, categories.name, categories.logo, sum(amount) as total_amount, count(*) as purchase_count, max(date) as most_recent",
              :order =>       "total_amount desc")

  end

  
  def self.payer_purchases_the_works(payer_id)
    self.find_all_by_payer_id(payer_id, 
               :joins  =>      "inner join products on purchases.product_id = products.id inner join categories on products.category_id = categories.id inner join consumers on purchases.consumer_id = consumers.id inner join retailers on purchases.retailer_id = retailers.id",
               :select =>      "purchases.id, consumers.id as consumer_id, consumers.name as consumer_name, retailers.id as retailer_id, retailers.name as retailer_name, retailers.logo as retailer_logo, products.id as product_id, products.title as product_title, categories.id as category_id, categories.name as category_name, amount, date, authorized, authorization_type, authorization_date",
               :order =>       "date desc")

  end

  
   
end
