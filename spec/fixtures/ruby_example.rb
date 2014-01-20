class Teste < BostadeTeste
  include BostaRala
  
  def metodo(arg1=TesteClasse, arg2)
    a = ClasseQueNaoExiste.new
    a.soma(1+2)
    b = a
  end
  
  def falaAlgo
    b = ClasseDeTeste::Em::OutroModulo.new('a')
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

def testedemetodosozinho
  
end