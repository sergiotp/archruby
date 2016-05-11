require 'spec_helper'

describe Archruby::Ruby::TypeInference::Ruby::ProcessMethodBody do
  let(:method_example_content) { File.read(File.expand_path('../../fixtures/methodbody_1.rb', __FILE__)) }
  let(:ruby_parser) { RubyParser.new }

  before(:each) do
    sexp = ruby_parser.parse(method_example_content)
    _, method_name, method_arguments, *method_body = sexp
    current_scope = Archruby::Ruby::TypeInference::Ruby::LocalScope.new
    @result = Archruby::Ruby::TypeInference::Ruby::ProcessMethodBody.new(method_body, current_scope).parse
  end

  it "return the correct amount of method calls" do
    expect(@result.size).to be_equal(4)
  end

  it "parse the method body correctly" do
    fake_method_invocation = Archruby::Ruby::TypeInference::Ruby::InternalMethodInvocation.new(
      "AnotherClass",
      :another_method,
      ["AnyClass", "ClassTeste"],
      5
    )
    last_method_call = @result.last
    expect(last_method_call.class_name).to be_eql(fake_method_invocation.class_name)
    expect(last_method_call.linenum).to be_eql(fake_method_invocation.linenum)
  end
end
