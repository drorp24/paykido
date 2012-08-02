class AdminController < ActionController::Base

  def populate_title
    for purchase in Purchase.all
      purchase.properties['title'] = 'farmville'
      purchase.properties['category'] = 'Online Games'
      purchase.properties['esrb_rating'] = 'E'
      purchase.properties['pegi_rating'] = '3'
      purchase.save!
    end
    
    info = Info.new
    info.key = 'retailer'
    info.value = 'Zynga'
    info.title = 'Zynga'
    info.description = "As of April 2012, Zynga's games have over 292 million monthly active users. Five of Zynga's games, CityVille, Zynga Poker, FarmVille, CastleVille, and Hidden Chronicles, are the most widely used game applications on Facebook, with CityVille having over 40 million monthly active users. Connecting the world through games is the company's mission."
    info.logo = 'zynga logo.png'
    info.save!
    
    info = Info.new
    info.key = 'title'
    info.value = 'farmville'
    info.title = 'Farmville'
    info.description = "FarmVille is a casual farming simulation social network game developed by Zynga in 2009. Gameplay involving various aspects of farm management such as plowing land, planting, growing and harvesting crops, harvesting trees and bushes, and raising livestock.  The game is a freemium game, meaning there is no cost to play but players have the option of purchasing premium content. As of September 2011, FarmVille is the third most popular Facebook game, behind CityVille and The Sims Social."
    info.logo = 'farmville.png'
    info.save!
    
    redirect_to payer_purchases_path(1)
  end 
  
  def populate_rest
    info = Info.new
    info.key = 'title'
    info.value = 'farmville'
    info.title = 'Farmville'
    info.description = "FarmVille is a casual farming simulation social network game developed by Zynga in 2009. Gameplay involving various aspects of farm management such as plowing land, planting, growing and harvesting crops, harvesting trees and bushes, and raising livestock.  The game is a freemium game, meaning there is no cost to play but players have the option of purchasing premium content. As of September 2011, FarmVille is the third most popular Facebook game, behind CityVille and The Sims Social."
    info.logo = 'farmville.png'
    info.save!
        
  end
 
end
