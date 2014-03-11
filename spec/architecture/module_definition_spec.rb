require 'spec_helper'

describe ArchChecker::Architecture::ModuleDefinition do
  let(:parsed_yaml) {YAML.load_file(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__))}
  let(:parser) {ArchChecker::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }
  
  it 'get file content correctly' do    
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = ArchChecker::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = ArchChecker::Architecture::ModuleDefinition.new(config_definition, base_directory)
    module_definition.classes.should include("Teste")
    module_definition.classes.should include("User")
    module_definition.dependencies.should include("ActiveRecord::Base")
    module_definition.dependencies.should include("OutraClasse::De::Teste")    
    module_definition.classes_and_dependencies.first.keys.should include("Teste")
    module_definition.classes_and_dependencies.last.keys.should include("User")
  end
  
  it 'return true when the module has a particular class' do
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = ArchChecker::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = ArchChecker::Architecture::ModuleDefinition.new(config_definition, base_directory)    
    module_definition.is_mine?("Teste").should be_true
    module_definition.is_mine?("User").should be_true
    module_definition.is_mine?("ActiveRecord").should be_false
    module_definition.is_mine?("QualquerCoisa").should be_false    
  end
  
  it 'verify required constraint correctly' do
    architecture = ArchChecker::Architecture::Architecture.new(parser.modules)
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = ArchChecker::Architecture::ConfigDefinition.new 'model', parsed_yaml['model']
    module_definition = ArchChecker::Architecture::ModuleDefinition.new(config_definition, base_directory)
    required_breaks = module_definition.verify_required architecture
    required_breaks.count.should == 1
    required_breaks.first.class_origin.should == "Teste"
  end
  
  it 'verify forbidden constraint correctly' do
    architecture = ArchChecker::Architecture::Architecture.new(parser.modules)
    base_directory = File.expand_path('../../dummy_app/', __FILE__)
    config_definition = ArchChecker::Architecture::ConfigDefinition.new 'view', parsed_yaml['view']
    module_definition = ArchChecker::Architecture::ModuleDefinition.new(config_definition, base_directory)
    forbidden_breaks = module_definition.verify_forbidden architecture
    forbidden_breaks.count.should == 1
    forbidden_breaks.first.class_origin.should == "ViewTest"
  end
  
end