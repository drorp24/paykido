class Allowance < ActiveRecord::Base
  include IceCube
  
  belongs_to  :consumer

  def schedule=(new_schedule)
    write_attribute(:schedule, new_schedule.to_yaml)
  end

  def schedule
    IceCube::Schedule.from_yaml(read_attribute(:schedule)) unless read_attribute(:schedule).nil?
  end

end
