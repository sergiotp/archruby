require 'spec_helper'

describe ArchChecker::ExtractArchitecture do
  let(:arch_extractor) { ArchChecker::ExtractArchitecture.new }
  let(:dependencies) { arch_extractor.extract_classes_and_dependencies }

  it 'extract file content correctly' do
    content_files = arch_extractor.extract_content_files    
    content_files.first.keys.should include(:controller)
  end
  
  it 'extract class and file dependencies correctly' do
    dependencies = arch_extractor.extract_classes_and_dependencies
    dependencies.first.keys.should include(:controller)
    dependencies.first[:controller][:classes].should include("ApplicationController")
    dependencies.first[:controller]['application_controller'].should include("ActionController")
  end
  
  it 'verify architecture constraints correctly' do

    arch_extractor.check_constraints dependencies
  end
  
end
