require 'spec_helper'

describe Archruby::ExtractArchitecture do
  let(:arch_extractor) { Archruby::ExtractArchitecture.new(
      File.expand_path("../../spec/fixtures/new_arch_definition.yml", __FILE__),
      File.expand_path("../../spec/dummy_app/", __FILE__)
    )
  }

  let(:fake_constraint) {
    Archruby::Architecture::ConstraintBreak.new({
      :type => Archruby::Architecture::ConstraintBreak::DIVERGENCE,
      :class_origin => "ApplicationController",
      :line_origin => 7,
      :class_target => "Koala::Facebook::API",
      :module_origin => "controller",
      :module_target => "facebook",
      :msg => "module controller is not allowed to depend on module facebook"
      })
  }

  it 'extract dependencies' do
    architecture_violations = arch_extractor.verify
    divergence = architecture_violations.first
    expect(fake_constraint.type).to be_eql(divergence.type)
    #binding.pry

  end

end
