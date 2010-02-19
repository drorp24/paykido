class Subscriber < ActiveRecord::Base
  belongs_to :payer
  validates_presence_of :billing_phone
  validates_uniqueness_of :billing_phone

  attr_accessor :id, :billing_phone, :payer_id
  
  def initialize(billing_phone)
    @billing_phone = billing_phone
  end
  

end
