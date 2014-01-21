require 'spec_helper'

describe ArchChecker::ExtractArchitecture do
  let(:arch_extractor) { ArchChecker::ExtractArchitecture.new }

  it 'extract file content correctly' do
    arch_extractor.parse_config_file
    content_files = arch_extractor.extract_content_files
    
    content_files.first.keys.should include(:controller)
    
  end
  
  it 'extract file dependencies correctly' do
    dependencies = arch_extractor.extract_classes_and_dependencies
    puts dependencies.inspect
  end
  
end
