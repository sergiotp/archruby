require 'spec_helper'

describe Archruby::Architecture::Parser do
  let(:parser) {Archruby::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }

  it 'extract correct modules from architecture definition file' do
    parser.modules.should_not be_empty
    parser.modules.count.should be_eql(12)
  end

end
