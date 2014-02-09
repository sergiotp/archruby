require 'spec_helper'

describe ArchChecker::ExtractArchitecture do
  let(:arch_extractor) { ArchChecker::ExtractArchitecture.new("../../spec/fixtures/arch_definition.yml", "/Users/sergiomiranda/Labs/ruby_arch_checker/arch_checker/spec/dummy_app/") }
  let(:dependencies) { arch_extractor.extract_classes_and_dependencies }

  it '' do
  end
  
end
