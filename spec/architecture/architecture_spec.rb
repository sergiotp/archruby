require 'spec_helper'

describe Archruby::Architecture::Architecture do
  let(:parser) { Archruby::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }
  let(:architecture) { Archruby::Architecture::Architecture.new(parser.modules) }

  it 'have an unknown_module' do
    architecture.unknown_module.should_not be_nil
    architecture.unknown_module.name.should be_eql("unknown")
  end

  it 'detect the amount of architecture erosion correctly' do
    architecture.verify
    architecture.constraints_breaks.count.should == 5
  end

  it 'raise and error if how_many_break is called without verify the architecture' do
    lambda{ architecture.how_many_break("module_name", "module_target_name", "constraint_type") }.should raise_error(Archruby::ArchitectureNotVerified)
  end

  it 'return the amount of constraint breaks correctly' do
    architecture.verify
    controller_breaks = architecture.how_many_break "controller", "facebook", Archruby::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)

    controller_breaks = architecture.how_many_break "model", "activerecord", Archruby::Architecture::ConstraintBreak::ABSENSE
    controller_breaks.should be_eql(2)

    controller_breaks = architecture.how_many_break "model", "facebook", Archruby::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)

    controller_breaks = architecture.how_many_break "view", "model", Archruby::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)
  end

  it 'return the module name correctly' do
    architecture.module_name("ActionController").should be_eql("actioncontroller")
    architecture.module_name("Koala").should be_eql("facebook")
    architecture.module_name("User").should be_eql("model")
    architecture.module_name("NAOTEMNAO").should be_eql(architecture.unknown_module.name)
  end

  it 'return the correct amount of time that an module access another module' do
    architecture.how_many_access_to("controller", "model").should be_eql(2)
    architecture.how_many_access_to("model", "controller").should be_eql(1)
  end
end
