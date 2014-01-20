require 'spec_helper'

describe ArchChecker::Ruby::Parser do
  it 'should parse ruby files correctly and return the dependencies' do
    ruby_file_content = File.open(File.expand_path('../../fixtures/ruby_example.rb', __FILE__), 'r').read
    
    ruby_parser = ArchChecker::Ruby::Parser.new(ruby_file_content)
    ruby_parser.parse
    
    ruby_parser.dependencies.should include("BostadeTeste")
    ruby_parser.dependencies.should include("BostaRala")
    ruby_parser.dependencies.should include("TesteClasse")
    ruby_parser.dependencies.should include("BostaQualquer")
    
    puts ruby_parser.dependencies.inspect
  end
end