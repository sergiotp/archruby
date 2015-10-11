require 'spec_helper'

describe Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference do
  before do
    @fixtures_path = File.expand_path('../fixtures', __FILE__)
  end

  it "parse the file correctly" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/teste_class_and_args.rb")
    dependencies, methods = parser.parse(file_content)
    first_parsed_class = methods[0]
    expect(first_parsed_class.class_name).to eql("Teste")
    expect(first_parsed_class.method_calls.count).to eql(7)
    method_calls = first_parsed_class.method_calls
    expect(method_calls[2].class_name).to eql("C::D")
    expect(method_calls[2].method_name).to eql(:some_method)
    expect(method_calls[2].params[0]).to eql(:param1)
  end

  it "parse the file correctly 2" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/teste_class_and_args2.rb")
    dependencies, methods = parser.parse(file_content)
    expect(dependencies.size).to be_eql(2)
    expect(methods.size).to be_eql(1)
    method = methods[0]
    expect(method.method_name).to be_eql(:initialize)
    method_calls = method.method_calls
    expect(method_calls.size).to be_eql(3)
    expect(method_calls[0].method_name).to be_eql(:is_a?)
    expect(method_calls[0].params).to include("ActionView::LookupContext")
    expect(method_calls[1].method_name).to be_eql(:new)
    expect(method_calls[1].params).to include(:context)
    expect(method_calls[2].method_name).to be_eql(:new)
    expect(method_calls[2].params).to include("ActionView::LookupContext")
  end

  it "parse the file correctly 3" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/rails_action_view_class_teste.rb")
    dependencies, methods = parser.parse(file_content)
    expect(dependencies.first.dependencies).to include("Helpers")
    expect(dependencies[8].dependencies).to include("ActiveSupport::InheritableOptions")
    expect(dependencies[8].dependencies).to include("ActionView::LookupContext")
    expect(dependencies[8].dependencies).to include("ActionView::Renderer")
  end

  it "parse the file correctly 4" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/rails_active_record_class.rb")
    dependencies, methods = parser.parse(file_content)
  end

  it "parse the file correclty 5" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/homebrew_bottles_class.rb")
    dependencies, methods = parser.parse(file_content)
    expect(dependencies.last.dependencies).to include("MacOS::Version")
  end

  it "parse the file correclty 6" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/homebrew_brew_teste.rb")
    dependencies, methods = parser.parse(file_content)

  end

end
