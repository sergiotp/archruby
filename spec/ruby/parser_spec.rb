require 'spec_helper'

describe ArchChecker::Ruby::Parser do
  let(:ruby_content_file) { File.open(File.expand_path('../../fixtures/ruby_example.rb', __FILE__), 'r').read }
  let(:ruby_parser) { ArchChecker::Ruby::Parser.new(ruby_content_file) }
  
  it 'should parse ruby files correctly and return the dependencies' do

    ruby_parser.dependencies.should include("BostadeTeste")
    ruby_parser.dependencies.should include("BostaRala")
    ruby_parser.dependencies.should include("TesteClasse")
    ruby_parser.dependencies.should include("BostaQualquer")    
  end
  
  it 'extract correct class from file' do
    
    ruby_parser.classes.should include("Teste")
    ruby_parser.classes.should include("BostaOutra")
  end
  
end