require 'spec_helper'

describe Archruby::Ruby::Parser do
  let(:ruby_content_file) { File.open(File.expand_path('../../fixtures/ruby_example.rb', __FILE__), 'r').read }
  let(:ruby_content_file_typeinference) { File.open(File.expand_path('../../fixtures/ruby_example_typeinference.rb', __FILE__), 'r').read }
  let(:ruby_parser) { Archruby::Ruby::Parser.new(ruby_content_file) }

  it 'should parse ruby files correctly and store type information' do
    parser = Archruby::Ruby::Parser.new ruby_content_file_typeinference
    # class_methods_dep = parser.type_inference
    # class_methods_calls = parser.method_calls
    # typer = Archruby::Architecture::TypeInferenceChecker.new class_methods_dep, class_methods_calls
    # class_methods_calls.each do |method_call|
    #   if !method_call[:method_call_params].nil?
    #     method_call[:method_call_params].each do |param|
    #       if method_call[:method_arguments].include? param
    #         param_position = method_call[:method_arguments].index param
    #         if !param_position.nil?
    #           class_methods_dep.each do |dep|
    #             if dep[:class_name] == method_call[:class]
    #               class_dep = dep[:dep][param_position]
    #               new_dep = Archruby::Ruby::TypeInferenceDep.new(
    #                 :class_dep => class_dep.class_dep
    #               )
    #               class_methods_dep << {
    #                 :class_name => method_call[:class_call],
    #                 :method_name => method_call[:method_call],
    #                 :dep => new_dep
    #               }
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
    # typer.verify_types
    # puts
    # puts class_methods_dep.inspect
    # puts class_methods_calls.inspect
    # puts
    # puts 'TYPER'
    # puts typer.method_and_deps.inspect
    # puts typer.method_calls.inspect
  end

  it 'should parse ruby files correctly and return the dependencies' do
    ruby_parser.dependencies.should include("BostadeTeste::Testado")
    ruby_parser.dependencies.should include("BostaRala")
    ruby_parser.dependencies.should include("TesteClasse")
    ruby_parser.dependencies.should include("BostaQualquer")
    ruby_parser.dependencies.should include("ClasseDeTeste::Em::OutroModulo::NaPQP")
  end

  it 'extract correct class from file' do
    ruby_parser.classes.should include("Teste")
    ruby_parser.classes.should include("BostaOutra")
    ruby_parser.classes.should include("Multiple::Access::Teste")
  end

  it 'extract correct classes and depencies' do
    ruby_parser.classes_and_dependencies.keys.count.should be_eql(3)
    ruby_parser.classes_and_dependencies['Teste'].count.should be_eql(11)
    ruby_parser.classes_and_dependencies['BostaOutra'].count.should be_eql(1)
    ruby_parser.classes_and_dependencies['Modulo::ClasseDentrodoModulo'].count.should be_eql(2)

    teste_class_dependencies = ruby_parser.classes_and_dependencies['Teste'].collect { |dependency| dependency.class_name}
    bosta_outra_class_dependencies = ruby_parser.classes_and_dependencies['BostaOutra'].collect { |dependency| dependency.class_name}
    classe_dentro_do_modulo_dependencies = ruby_parser.classes_and_dependencies['Modulo::ClasseDentrodoModulo'].collect { |dependency| dependency.class_name}

    teste_class_dependencies.should include("ClasseDeTeste::Em::OutroModulo::NaPQP")
    teste_class_dependencies.should include("BostadeTeste::Testado")

    bosta_outra_class_dependencies.should include("BostaQualquer")

    classe_dentro_do_modulo_dependencies.should include("::Teste::De::Dependencia")
    classe_dentro_do_modulo_dependencies.should include("::DependenciaBuscandoDoRoot")
  end

end
