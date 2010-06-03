class Consumer < ActiveRecord::Base
  
  belongs_to :payer
  
#  attr_accessor :billing_phone, :payer_id
  
#  def initialize (consumer)
#    super()
#    @billing_phone = consumer[:billing_phone]
#  end
  
  validates_presence_of :billing_phone
  validates_numericality_of :billing_phone
  validates_length_of :billing_phone, :is => 10

  def pin
    @pin
  end
  
  def pin=(val)
    
  end
   
   
end