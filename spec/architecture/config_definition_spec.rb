require 'spec_helper'

describe ArchChecker::Architecture::ConfigDefinition do
  let(:parsed_yaml) {YAML.load_file(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__))}
  let(:mocked_yaml) { {"controller"=> {"files"=>"app/controllers/**/*.rb", "allowed"=>"model, integracao_twitter, facebook_looker, actioncontroller", "forbidden" => ["forbidden_module"]}} }
  
  it 'return all information correctly' do
    config_definition = ArchChecker::Architecture::ConfigDefinition.new 'controller', parsed_yaml['controller']
    config_definition.files.count.should == 1
    config_definition.gems.should be_empty
    config_definition.required_modules.should be_empty
    config_definition.forbidden_modules.should be_empty
    config_definition.allowed_modules.should include("integracao_twitter")
    config_definition.allowed_modules.should include("model")
  end
  
  it 'throw an execption if allowed and forbidden is used thogheter' do 
    lambda { config_definition = ArchChecker::Architecture::ConfigDefinition.new 'controller', mocked_yaml['controller'] }.should raise_error(ArchChecker::MultipleConstraints)
  end
end