module ProximoParty
  url = ENV['PROXIMO_URL']
  url = "http://proxy:301396998fc6-411a-a71c-3a039ee3d61b@proxy-23-21-132-4.proximo.io" if url.blank?
  PROXIMO = URI.parse(url)


  def self.included(base)
    base.send(:include, HTTParty)
    base.http_proxy(PROXIMO.host, 80, PROXIMO.user, PROXIMO.password)
  end

end