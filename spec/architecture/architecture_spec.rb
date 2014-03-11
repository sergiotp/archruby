require 'spec_helper'

describe ArchChecker::Architecture::Architecture do
  let(:parser) { ArchChecker::Architecture::Parser.new(File.expand_path('../../fixtures/new_arch_definition.yml', __FILE__), File.expand_path('../../dummy_app/', __FILE__)) }
  let(:architecture) { ArchChecker::Architecture::Architecture.new(parser.modules) }

  it 'detect the amount of architecture erosion correctly' do
    architecture.verify
    architecture.constraints_breaks.count.should == 4
  end
  
  it 'raise and error if how_many_break is called without verify the architecture' do 
    lambda{ architecture.how_many_break("module_name", "constraint_type") }.should raise_error(ArchChecker::ArchitectureNotVerified)
  end
  
  it 'return the amount of constraint breaks correctly' do
    architecture.verify
    controller_breaks = architecture.how_many_break "controller", ArchChecker::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)
    
    controller_breaks = architecture.how_many_break "model", ArchChecker::Architecture::ConstraintBreak::ABSENSE
    controller_breaks.should be_eql(1)
    
    controller_breaks = architecture.how_many_break "model", ArchChecker::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)
    
    controller_breaks = architecture.how_many_break "view", ArchChecker::Architecture::ConstraintBreak::DIVERGENCE
    controller_breaks.should be_eql(1)
  end
  
  it 'return the module name correctly' do
    architecture.module_name("ActionController").should be_eql("actioncontroller")
    architecture.module_name("Koala").should be_eql("facebook")
    architecture.module_name("User").should be_eql("model")    
  end
  
  it 'return the correct amount of time that an module access another module' do
    architecture.how_many_access_to("controller", "model").should be_eql(2)
  end
end