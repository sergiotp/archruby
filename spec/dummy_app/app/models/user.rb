class User < ActiveRecord::Base
  def teste
    a = IntegracaoTwitter.new
  end

  def break
    b = ApplicationController.new
  end

  def metodo_teste a
    a.get
  end
end
