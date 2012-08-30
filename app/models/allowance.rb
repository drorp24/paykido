class Allowance < ActiveRecord::Base
  include IceCube
#  serialize :schedule, Hash
  
  belongs_to  :consumer

=begin  
  def schedule=(new_schedule)
    write_attribute(:schedule, new_schedule.to_hash)
  end

  def schedule
    IceCube::Schedule.from_hash(read_attribute(:schedule))
  end
=end  
end
