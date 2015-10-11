class Teste
  def a(param1=Professor.new, param2=Student.new)
    b = School.new
    b.some_method(param1)
    c = Exame.new
    c.another_method(b)
    s = QI.new
    s.some_other_method(A::T)
  end
end

class Teste2
  def teste(a = Teste, b = RubyTeste)
    a = 1
  end
end
