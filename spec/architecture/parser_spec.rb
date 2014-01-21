require 'spec_helper'

describe ArchChecker::Architecture::Parser do
  let(:parser) {ArchChecker::Architecture::Parser.new(File.expand_path('../../fixtures/arch_definition.yml', __FILE__)) }

  it 'extract correct modules from architecture definition file' do 
    parser.parse
    
    parser.modules.keys.should include(:controller)
    parser.modules.keys.should include(:model)
    parser.modules.keys.should include(:view)
    parser.modules.keys.should include(:integracao_twitter)
  end
  
  it 'extract correct dependencies from architecture definition file' do
    parser.parse
    
    parser.dependencies.keys.should include(:only)
    parser.dependencies.keys.should include(:view)
  end  
end