class Consumer < ActiveRecord::Base
  
  belongs_to :payer
  
#  attr_accessor :billing_phone, :payer_id
  
#  def initialize (consumer)
#    super()
#    @billing_phone = consumer[:billing_phone]
#  end
  
  validates_presence_of :billing_phone
  validates_uniqueness_of :billing_phone

   
   
end