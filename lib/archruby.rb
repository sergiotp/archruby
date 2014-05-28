require "archruby/version"

require 'archruby/architecture/parser'
require 'archruby/architecture/config_definition'
require 'archruby/ruby/parser'
require 'archruby/ruby/std_library'
require 'archruby/ruby/core_library'
require 'archruby/ruby/var_propagation'
require 'archruby/architecture/file_content'
require 'archruby/architecture/module_definition'
require 'archruby/architecture/dependency'
require 'archruby/architecture/constraint_break'
require 'archruby/architecture/architecture'
require 'archruby/presenters/text'
require 'archruby/presenters/graph'
require 'archruby/presenters/yaml'

module Archruby
  class ExtractArchitecture
    attr_reader :architecture

    def initialize config_file_path = "", base_directory = ""
      @config_file_path = config_file_path
      @base_directory = base_directory
      @architecture_definition = Archruby::Architecture::Parser.new(File.expand_path(@config_file_path, __FILE__), @base_directory)
      @architecture = Archruby::Architecture::Architecture.new(@architecture_definition.modules)
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

  class MultipleConstraints < Archruby::Error; status_code(2) ; msg("Allowed and Forbidden in same module definition") end
  class ArchitectureNotVerified < Archruby::Error; status_code(3) ; msg("The architecture need to be verified first") end
end