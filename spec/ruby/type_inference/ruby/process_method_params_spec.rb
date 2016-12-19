require 'spec_helper'

describe Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams do
  let(:method_param_content) { File.read(File.expand_path('../../fixtures/methodparams_1.rb', __FILE__)) }
  let(:ruby_parser) { RubyParser.new }

  before(:each) do
    sexp = ruby_parser.parse(method_param_content)
    _, method_name, method_arguments, *method_body = sexp
    method_body_calls = []
    method_body.map {|m| method_body_calls << m if m.node_type == :call }
    @collected_params = []
    method_body_calls.each do |method_call|
      _, receiver, method_name, *params = method_call
      @collected_params << params
    end
  end

  it "return the paramiters used in the method calls" do

    current_scope = Archruby::Ruby::TypeInference::Ruby::LocalScope.new

    result1, result_new = Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams.new(@collected_params.first, current_scope).parse
    result2, result_new2 = Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams.new(@collected_params.last, current_scope).parse

    expect(result1).to be_eql([:a, :b, :c])
    expect(result2).to be_eql([:ClassTest, :a])
  end

  it "return the paramiters used with the correct type" do
    current_scope = Archruby::Ruby::TypeInference::Ruby::LocalScope.new
    current_scope.add_variable(:a, "A")
    current_scope.add_variable(:b, "B")
    current_scope.add_variable(:c, "C")

    result1, result_new = Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams.new(@collected_params.first, current_scope).parse
    result2, result_new2 = Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams.new(@collected_params.last, current_scope).parse

    expect(result1).to be_eql(["A", "B", "C"])
    expect(result2).to be_eql([:ClassTest, "A"])
  end
end
