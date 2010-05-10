class Category < ActiveRecord::Base
  
  has_many :products
  has_many :purchases, :through => :products
      
  has_many :clists
  has_many :payers, :through => :clists    # to be used for queries such as "who blacklists me" (not likely)

  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def clist(payer_id)
    
    clist = Clist.find_or_initialize_by_category_id_and_payer_id(self.id, payer_id)
    
  end
  
  def status(payer_id)

    self.clist(payer_id).status
    
  end
  
  def update(payer_id, status)
    
    self.clist(payer_id).update_attributes!(:status => status)
    
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