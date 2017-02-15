require 'spec_helper'

describe Archruby::Ruby::TypeInference::TypeInferenceChecker do
  before do
    @fixtures_path = File.expand_path('../fixtures', __FILE__)
  end

  it "mantains the dependencies and methods invocations correctly" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/teste_class_and_args.rb")
    dependencies, methods_calls = parser.parse(file_content)
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    verify_type = Archruby::Ruby::TypeInference::TypeInferenceChecker.new(
                    dependency_organizer.dependencies,
                    dependency_organizer.method_definitions
                  )
    verify_type.add_dependency_based_on_calls
    verify_type.add_dependency_based_on_internal_calls
    new_deps = verify_type.dependencies
    new_methods = verify_type.method_definitions
    expect(new_deps["Teste"]).to include("Y")
    expect(new_deps["Teste"]).to include("G")
    expect(new_deps["C::D"]).to include("Y")
    expect(new_methods["Teste"].first.args[:param1]).to include("Y")
    expect(new_methods["Teste"].first.args[:param2]).to include("G")
  end

  it "return the number of dependencies correctly" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/teste_class_and_args.rb")
    dependencies, methods_calls = parser.parse(file_content)
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    verify_type = Archruby::Ruby::TypeInference::TypeInferenceChecker.new(
                    dependency_organizer.dependencies,
                    dependency_organizer.method_definitions
                  )
    expect(verify_type.total_deps).to eql(12)
    verify_type.add_dependency_based_on_calls
    verify_type.add_dependency_based_on_internal_calls
    expect(verify_type.total_deps).to eql(18)
  end

  it "test types" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/teste_types.rb")
    dependencies, methods_calls = parser.parse(file_content)
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    verify_type = Archruby::Ruby::TypeInference::TypeInferenceChecker.new(
                    dependency_organizer.dependencies,
                    dependency_organizer.method_definitions
                  )
    new_deps = verify_type.dependencies
    new_methods = verify_type.method_definitions


    verify_type.add_dependency_based_on_calls
    verify_type.add_dependency_based_on_internal_calls

    new_methods = verify_type.method_definitions
    #binding.pry

  end

  it "test types 2" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/test_types2.rb")
    dependencies, methods_calls = parser.parse(file_content)
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    verify_type = Archruby::Ruby::TypeInference::TypeInferenceChecker.new(
                    dependency_organizer.dependencies,
                    dependency_organizer.method_definitions
                  )
    new_deps = verify_type.dependencies
    new_methods = verify_type.method_definitions


    verify_type.add_dependency_based_on_calls
    verify_type.add_dependency_based_on_internal_calls

    new_methods = verify_type.method_definitions
    #binding.pry
  end

  it "test type 3 " do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/test_types3.rb")
    dependencies, methods_calls = parser.parse(file_content)
    #binding.pry
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    verify_type = Archruby::Ruby::TypeInference::TypeInferenceChecker.new(
                    dependency_organizer.dependencies,
                    dependency_organizer.method_definitions
                  )
    new_deps = verify_type.dependencies
    new_methods = verify_type.method_definitions
  end

end
