class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def break_facebook_looker
    graph = Koala::Facebook::API.new("access_token_qualquer")
    a = Teste.new
    a.method(graph)
  end

  def access_an_user_model
    @users = User.all
  end

  def access_an_teste_model
    @teste = Teste.new
  end
end
