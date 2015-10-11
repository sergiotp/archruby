require 'spec_helper'

describe Archruby::Ruby::TypeInference::DependencyOrganizer do
  before do
    @fixtures_path = File.expand_path('../fixtures', __FILE__)
  end

  it "mantains the dependencies and methods invocations correctly" do
    parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
    file_content = File.read("#{@fixtures_path}/rails_action_view_class_teste.rb")
    dependencies, methods_calls = parser.parse(file_content)
    dependency_organizer = Archruby::Ruby::TypeInference::DependencyOrganizer.new
    dependency_organizer.add_dependencies(dependencies)
    dependency_organizer.add_method_calls(methods_calls)
    # acho que vou manter um hash com o nome da classe e o valor vai
    # ser um set com todas as dependencias dessa classe

    # Tenho que decidir o que vou fazer com as chamadas de metodo ainda
  end
end
