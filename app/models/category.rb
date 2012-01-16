class Category < ActiveRecord::Base
  
  has_many :products
  has_many :purchases, :through => :products
      
  has_many :clists
  has_many :payers, :through => :clists    # to be used for queries such as "who blacklists me" (not likely)

  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def blacklist!(payer_id, consumer_id)
    clist = Clist.find_or_initialize_by_category_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    clist.update_attributes!(:rule => 'blacklisted')
  end
  
  def blacklisted?(payer_id, consumer_id)
    Clist.where(:category_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'blacklisted').exists?
  end

  def whitelist!(payer_id, consumer_id)
    clist = Clist.find_or_initialize_by_category_id_and_payer_id_and_consumer_id(self.id, payer_id, consumer_id)
    clist.update_attributes!(:rule => 'whitelisted')
  end
  
  def whitelisted?(payer_id, consumer_id)
    Clist.where(:category_id => self.id, :payer_id => payer_id, :consumer_id => consumer_id, :rule => 'whitelisted').exists?
  end

  
 
end