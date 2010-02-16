class Subscriber < ActiveRecord::Base
  belongs_to :payer
  
  validates_presence_of :billing_phone
  validates_uniqueness_of :billing_phone

end
