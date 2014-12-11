class Test
  def metodo_test c, d, a
    d = 1
    a = Testa::Com::Classe.new
    param = Param.new
    d = ::Vai::La.new
    a.method(param, d)
    b = Teste.new
    b.vai(Bosta::RALA.new)
  end
end

class Testa::Com::Classe
  def method x
    b = OutraClasse.new
    b.chama(x)
  end
end

class Param

end

class Testa
  def method klass = A.new

  end
end

class NewClasse
end
