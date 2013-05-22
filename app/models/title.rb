class Title < ActiveRecord::Base

  def self.category(title)
    title_rec = self.find_by_name(title)
    title_rec.category if title_rec
  end

  def self.pegi_rating(title)
    title_rec = self.find_by_name(title)
    title_rec.pegi_rating if title_rec
  end

  def self.esrb_rating(title)
    title_rec = self.find_by_name(title)
    title_rec.esrb_rating if title_rec
  end
      
end
