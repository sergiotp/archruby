class A
  def foo
    puts "foo"
  end
end

class B

  def bar
    f = A.new
    bar2(f)
  end

  def bar2(x)
    x.foo
  end
end

b = B.new
b.bar
