class Retailer < ActiveRecord::Base
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :payers, :through => :purchases
  
  has_many :items
  has_many :products, :through => :items
  
  has_many :rlists
  has_many :payers, :through => :rlists    # to be used for queries such as "who blacklists me" (not likely)
  
  has_many :users

 def existing_retailer_name
    errors.add(:name, "is not defined yet as retailer") unless Retailer.find_by_name(self.name)
  end
  
  def user_global_uniqueness
    errors.add(:user, "name exists already") if Payer.find_by_user(self.user)
  end

  def rlist(payer_id)
    
    rlist = Rlist.find_or_initialize_by_retailer_id_and_payer_id(self.id, payer_id)
    
  end
  
  def status(payer_id)
    rlist = Rlist.find_by_retailer_id_and_payer_id(self.id, payer_id)
    rlist.status if rlist
    
  end
  
  def update(payer_id, status)
    
    self.rlist(payer_id).update_attributes!(:status => status)
    
  end
  
  def is_blacklisted(payer_id)
    
    self.status == "blacklisted" 
    
  end

  def is_whitelisted(payer_id)
    
    self.status == "whitelisted" 
 
  end

  def blacklist(payer_id)
    
    self.update(payer_id, "blacklisted")
    
  end
 
  def whitelist(payer_id)
    
   self.update(payer_id, "whitelisted")
    
  end
 
end
