class Config < ActiveRecord::Base

  def self.policy
    self.find(1)
  end

end
