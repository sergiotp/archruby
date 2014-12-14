require 'spec_helper'

describe Archruby::Architecture::ModuleDefinition do
  let(:parsed_yaml) {YAML.load_file(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__))}
  let(:parser) {Archruby::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }

  it 'get file content correctly' do
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.classes.should include("Teste::Testando::VaiAcessar")
    module_definition.classes.should include("Teste")
    module_definition.classes.should include("User")
    module_definition.dependencies.should include("ActiveRecord::Base")
    module_definition.dependencies.should include("OutraClasse::De::Teste")
    module_definition.classes_and_dependencies[1].keys.should include("Teste")
    module_definition.classes_and_dependencies.last.keys.should include("User")
  end

  it 'return true if the module has a class dependency' do
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.already_has_dependency?("User", "ActiveRecord::Base").should be_true
    module_definition.already_has_dependency?("User", "ClassQualquer").should be_false
  end

  it 'build the dependencies correctly' do
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.dependencies.count.should be_eql(6)
    module_definition.dependencies.should include("OutraClasse::De::Teste")
    module_definition.dependencies.should include("ActiveRecord::Base")
  end

  it 'return true when the module has a particular class' do
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.is_mine?("Teste").should be_true
    module_definition.is_mine?("User").should be_true
    module_definition.is_mine?("ActiveRecord").should be_false
    module_definition.is_mine?("QualquerCoisa").should be_false
    module_definition.is_mine?("::User").should be_true
    module_definition.is_mine?("::User::Nao::Sei").should be_false
    module_definition.is_mine?("Testando::VaiAcessar").should be_true

    config_definition = Archruby::Architecture::ConfigDefinition.new 'actioncontroller', parsed_yaml['actioncontroller']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.is_mine?("ActionController::Base").should be_true
  end

  it 'verify required constraint correctly' do
    architecture = Archruby::Architecture::Architecture.new(parser.modules)
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    required_breaks = module_definition.verify_required architecture
    required_breaks.count.should == 2
    required_breaks.first.class_origin.should == "Teste::Testando"
    required_breaks.last.class_origin.should == "Teste"
  end

  it 'verify forbidden constraint correctly' do
    architecture = Archruby::Architecture::Architecture.new(parser.modules)
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = Archruby::Architecture::ConfigDefinition.new 'view', parsed_yaml['view']
    module_definition = Archruby::Architecture::ModuleDefinition.new(config_definition, base_directory)
    forbidden_breaks = module_definition.verify_forbidden architecture
    forbidden_breaks.count.should == 1
    forbidden_breaks.first.class_origin.should == "ViewTest"
  end

end
