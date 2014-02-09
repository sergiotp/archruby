require "arch_checker/version"

require 'arch_checker/architecture/parser'
require 'arch_checker/ruby/parser'
require 'arch_checker/architecture/file_content'
require 'arch_checker/architecture/file_dependencies'
require 'arch_checker/architecture/module_definition'
require 'arch_checker/architecture/dependency'
require 'arch_checker/architecture/constraint_break'
require 'arch_checker/architecture/architecture'
require 'arch_checker/presenters/text'
require 'arch_checker/presenters/graph'
require 'arch_checker/presenters/yaml'

module ArchChecker
  class ExtractArchitecture
    def initialize config_file_path = "", base_directory = ""
      @config_file_path = config_file_path
      @base_directory = base_directory
      @architecture_definition = ArchChecker::Architecture::Parser.new(File.expand_path(@config_file_path, __FILE__), @base_directory)
      @architecture = ArchChecker::Architecture::Architecture.new(@architecture_definition.modules)
      @constraints_breaks = []
    end
    
    def verify
      @constraints_breaks = @architecture.verify
    end
  end
end

