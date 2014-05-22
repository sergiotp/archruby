require 'spec_helper'

describe Archruby::Architecture::ConstraintBreak do
  it "receive an hash of options and put it in the correct attributes" do
    arch_break = Archruby::Architecture::ConstraintBreak.new({
      :type => Archruby::Architecture::ConstraintBreak::ABSENSE,
      :class_origin => "Teste",
      :line_origin => 12,
      :class_target => "Target",
      :module_origin => "moduloOrig",
      :module_target => "moduloTarg",
      :msg => "MSG"
      })
    arch_break.type.should == Archruby::Architecture::ConstraintBreak::ABSENSE
    arch_break.class_origin.should == "Teste"
    arch_break.line_origin.should == 12
    arch_break.class_target.should == "Target"
    arch_break.module_origin.should == "moduloOrig"
    arch_break.module_target.should == "moduloTarg"
    arch_break.msg.should == "MSG"
  end
end
