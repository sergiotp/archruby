require 'spec_helper'

describe ArchChecker::Architecture::FileDependencies do

  it 'return an array of dependencies based on source content' do
    example_file = { 
      "application_controller" => "class ApplicationController < ActionController::Base\n  # Prevent CSRF attacks by raising an exception.\n  # For APIs, you may want to use :null_session instead.\n  protect_from_forgery with: :exception\nend\n" 
    }
    file_dependencies = ArchChecker::Architecture::FileDependencies.new(example_file['application_controller'])
    dependencies = file_dependencies.dependencies
    dependencies.should include("ActionController")
  end

end