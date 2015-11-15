require "archruby/version"
require 'pry'

require 'archruby/architecture/parser'
require 'archruby/architecture/config_definition'
require 'archruby/ruby/parser'
require 'archruby/ruby/std_library'
require 'archruby/ruby/core_library'
require 'archruby/ruby/var_propagation'
require 'archruby/ruby/type_inference_dep'
require 'archruby/ruby/type_inference/dependency_organizer'
require 'archruby/ruby/type_inference/type_inference_checker'
require 'archruby/ruby/type_inference/ruby/class_dependency'
require 'archruby/ruby/type_inference/ruby/internal_method_invocation'
require 'archruby/ruby/type_inference/ruby/method_definition'
require 'archruby/ruby/type_inference/ruby/parser_for_typeinference'
require 'archruby/ruby/type_inference/ruby/process_method_arguments'
require 'archruby/ruby/type_inference/ruby/process_method_body'
require 'archruby/ruby/type_inference/ruby/process_method_params'
require 'archruby/architecture/file_content'
require 'archruby/architecture/module_definition'
require 'archruby/architecture/type_inference_checker'
require 'archruby/architecture/dependency'
require 'archruby/architecture/constraint_break'
require 'archruby/architecture/architecture'
require 'archruby/presenters/text'
require 'archruby/presenters/graph'
require 'archruby/presenters/dsm'
require 'archruby/presenters/yaml'

module Archruby
  class ExtractArchitecture
    attr_reader :architecture

    def initialize(config_file_path = "", base_directory = "")
      @config_file_path = config_file_path
      @base_directory = base_directory
      config_path = File.expand_path(@config_file_path, __FILE__)
      @architecture_definition = Archruby::Architecture::Parser.new(config_path, @base_directory)
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
