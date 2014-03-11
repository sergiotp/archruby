class Teste
  include ClassedeTeste

  def method
    a = OutraClasse::De::Teste.new
  end
  
  def search_facebook
    @graph = Koala::Facebook::API.new("access_token_qualquer")    
  end
end