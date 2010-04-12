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
 
end
