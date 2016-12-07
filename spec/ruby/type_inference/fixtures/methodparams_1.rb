def some_method(a = A.new, b = B.new, c = {})
  another_class = AnotherClass.new
  another_class.method_call(a, b, c)
  some_class = SomeClass.new(b)
  some_class.invoke_metho(ClassTest.new, a, {b: 1, c: 2})
  #test this case another_class=some_class
end
