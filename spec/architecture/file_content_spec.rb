require 'spec_helper'

describe Archruby::Architecture::FileContent do

  it 'get the content from the right files' do
    file_reader = Archruby::Architecture::FileContent.new("/Users/sergiomiranda/Labs/ruby_arch_checker/arch_checker/spec/dummy_app/app/")
    content = file_reader.all_content_from_directory "controllers/**/*.rb"
    content.keys.should include('application_controller')
    content['application_controller'].should_not be_nil
  end

end
