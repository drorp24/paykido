class Retailer < ActiveRecord::Base
  
  has_many :purchases
  has_many :products, :through => :purchases
  has_many :payers, :through => :purchases
  
  has_many :items
  has_many :products, :through => :items
  
  has_many :rlists
  has_many :payers, :through => :rlists    # to be used for queries such as "who blacklists me" (not likely)
  
  has_many :users


  def blacklist!(payer_id, consumer_id)
    rlist = Rlist.find_or_initialize_by_retailer_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    rlist.update_attributes!(:rule => 'blacklisted')
  end
  
  def blacklisted?(payer_id, consumer_id)
    Rlist.where(:retailer_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'blacklisted').exists?
  end

  def whitelist!(payer_id, consumer_id)
    rlist = Rlist.find_or_initialize_by_retailer_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    rlist.update_attributes!(:rule => 'whitelisted')
  end
  
  def whitelisted?(payer_id, consumer_id)
    Rlist.where(:retailer_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'whitelisted').exists?
  end

  def record!(amount)
    self.collected += amount
    self.save!
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
  
     
end
