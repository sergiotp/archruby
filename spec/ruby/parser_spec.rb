require 'spec_helper'

describe ArchChecker::Ruby::Parser do
  let(:ruby_content_file) { File.open(File.expand_path('../../fixtures/ruby_example.rb', __FILE__), 'r').read }
  let(:ruby_parser) { ArchChecker::Ruby::Parser.new(ruby_content_file) }
  
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
  end
  
  it 'extract correct classes and depencies' do
    ruby_parser.classes_and_dependencies.keys.count.should be_eql(2)
    ruby_parser.classes_and_dependencies['Teste'].count.should be_eql(7)
    ruby_parser.classes_and_dependencies['BostaOutra'].count.should be_eql(1)
    
    teste_class_dependencies = ruby_parser.classes_and_dependencies['Teste'].collect { |dependency| dependency.class_name}
    bosta_outra_class_dependencies = ruby_parser.classes_and_dependencies['BostaOutra'].collect { |dependency| dependency.class_name}
    
    teste_class_dependencies.should include("ClasseDeTeste::Em::OutroModulo::NaPQP")
    teste_class_dependencies.should include("BostadeTeste::Testado")
    
    bosta_outra_class_dependencies.should include("BostaQualquer")
  end
  
end