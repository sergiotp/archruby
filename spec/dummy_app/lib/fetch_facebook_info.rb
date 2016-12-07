class FetchFacebookInfo
  def self.me token
    @graph = Koala::Facebook::API.new("access_token_qualquer")
    profile = @graph.get_object("me")
    profile
  end
end