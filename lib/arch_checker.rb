require "arch_checker/version"

require 'arch_checker/architecture/parser'
require 'arch_checker/architecture/config_definition'
require 'arch_checker/ruby/parser'
require 'arch_checker/architecture/file_content'
require 'arch_checker/architecture/module_definition'
require 'arch_checker/architecture/dependency'
require 'arch_checker/architecture/constraint_break'
require 'arch_checker/architecture/architecture'
require 'arch_checker/presenters/text'
require 'arch_checker/presenters/graph'
require 'arch_checker/presenters/yaml'

module ArchChecker
  class ExtractArchitecture
    attr_reader :architecture
    
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
  
  class Error < StandardError
    def self.status_code(code)
      define_method(:status_code) { code }
    end
    
    def self.msg(msg)
      define_method(:msg) { msg }
    end
  end
  
  class MultipleConstraints < ArchChecker::Error; status_code(2) ; msg("Allowed and Forbidden in same module definition") end
end

