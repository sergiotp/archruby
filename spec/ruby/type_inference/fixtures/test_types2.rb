class Goiaba
  private
  def foo
    puts "Goiaba Foo (: !"
  end
end

class Manga
  private
  def foo
    puts "Manga Foo (: !"
  end
end

class MyClass

  def callFoo(x, y = {}, z = [])
    x.send(:foo)
  end

  def bar
    g = Goiaba.new
    callFoo(g)
    m = Manga.new
    callFoo(m,"arg2",g)
  end
end

myClass = MyClass.new
myClass.bar()
