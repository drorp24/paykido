module ApplicationHelper

# refuses to work, tired of trying. 

  def consumer_icon(consumer)
    
    if consumer.tinypic
      raw "<span class='avatar fr'><%= image_tag consumer.tinypic %></span>"
    else
      raw "<span class='icon32 user fr'></span>"
    end

  end

end
