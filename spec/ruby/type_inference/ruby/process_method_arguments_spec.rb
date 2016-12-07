require 'spec_helper'

describe Archruby::Ruby::TypeInference::Ruby::ProcessMethodArguments do
  let(:method_arguments_content) { File.read(File.expand_path('../../fixtures/methodarguments_1.rb', __FILE__)) }
  let(:ruby_parser) { RubyParser.new }

  it "parse the method arguments correctly" do
    fake_method_params = [:a, :c, :d]
    sexp = ruby_parser.parse(method_arguments_content)
    _, method_name, method_arguments, *method_body = sexp

    args = Archruby::Ruby::TypeInference::Ruby::ProcessMethodArguments.new(method_arguments).parse
    expect(args[fake_method_params[0]]).to include("B")
    expect(args[fake_method_params[1]]).to include("C")
    expect(args[fake_method_params[2]]).to include("D")

  end
end
