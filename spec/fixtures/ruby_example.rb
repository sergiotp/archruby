class Teste < BostadeTeste::Testado
  include BostaRala
  
  def metodo(arg1=TesteClasse, arg2)
    a = ClasseQueNaoExiste.new
    a.soma(1+2)
    b = a
  end
  
  def falaAlgo
    b = ClasseDeTeste::Em::OutroModulo::NaPQP.new('a')
    return b
  end
  
  def teste2
    a = {'a' => Dependencia.new, :b => Dependencia2.new}
  end
end

class BostaOutra < BostaQualquer
  def imprimebosta
    ok.each do |a|
      puts a.inspect
    end
  end
end

class Multiple::Access::Teste 
end

def testedemetodosozinho
  
end

module Modulo
  class ClasseDentrodoModulo
    def teste
      ::Teste::De::Dependencia.new
    end
    
    def outro_teste
      ::DependenciaBuscandoDoRoot.new
    end    
  end
  
  class ClasseDentroDoModulo2
  end
end