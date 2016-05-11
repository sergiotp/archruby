require 'spec_helper'

describe Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams do
  let(:method_param_content) { File.read(File.expand_path('../../fixtures/methodparams_1.rb', __FILE__)) }
  let(:ruby_parser) { RubyParser.new }

  it "parse the parms correctly" do
    sexp = ruby_parser.parse(method_param_content)
    _, method_name, method_arguments, *method_body = sexp
    method_body_calls = []
    method_body.map {|m| method_body_calls << m if m.node_type == :call }
    collected_params = []
    method_body_calls.each do |method_call|
      _, receiver, method_name, *params = method_call
      collected_params << params.first
    end
    current_scope = Archruby::Ruby::TypeInference::Ruby::LocalScope.new
    binding.pry
    result = Archruby::Ruby::TypeInference::Ruby::ProcessMethodParams.new(params, current_scope).parse
    binding.pry
  end
end
