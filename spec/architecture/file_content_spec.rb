require 'spec_helper'

describe Archruby::Architecture::FileContent do

  it 'get the content from the right files' do
    fake_app_path = File.expand_path('../../dummy_app/app', __FILE__)
    file_reader = Archruby::Architecture::FileContent.new(fake_app_path)
    content = file_reader.all_content_from_directory "controllers/**/*.rb"
    content.keys.should include('application_controller')
    content['application_controller'].should_not be_nil
  end

end
