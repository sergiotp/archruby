require 'spec_helper'

describe ArchChecker::Architecture::Architecture do
  let(:parser) {ArchChecker::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }
  
  it 'detect architecture erosion correctly' do
    architecture = ArchChecker::Architecture::Architecture.new(parser.modules)
    architecture.verify
    puts architecture.constraints_breaks.count
    puts architecture.constraints_breaks.inspect
    puts "YAMLLLL"
    puts ArchChecker::Presenters::Yaml.new.render(architecture)
  end
end