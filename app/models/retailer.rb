class Retailer < ActiveRecord::Base
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :payers, :through => :purchases
  
  has_many :items
  has_many :products, :through => :items
  
  has_many :rlists
  has_many :payers, :through => :rlists    # to be used for queries such as "who blacklists me" (not likely)
  
  has_many :users


  def add(amount)
    self.collected += amount
  end
  
  def rlist(payer_id)
    
    Rlist.find_or_initialize_by_retailer_id_and_payer_id(self.id, payer_id)
    
  end
  
  def status(payer_id)

    rlist(payer_id).status
    
  end
  
  def update(payer_id, status)
    
    rlist(payer_id).update_attributes!(:status => status)
    
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
   
end
