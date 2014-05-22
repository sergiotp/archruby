require 'yaml'

module Archruby
  module Architecture

    class Parser
      attr_reader :modules

      def initialize config_file_path, base_path
        @config_file = config_file_path
        @base_path = base_path
        @modules = []
        parse
        ruby_std_lib_module
        ruby_core_module
        unknow_module
      end

      def parse
        parsed_yaml = yaml_parser.load_file @config_file
        parsed_yaml.each do |module_name, definitions|
          begin
            config_definition = Archruby::Architecture::ConfigDefinition.new module_name, definitions
            module_definition = Archruby::Architecture::ModuleDefinition.new config_definition, @base_path
          rescue ArchChecker::MultipleConstraints => e
            STDOUT.puts "The config file is not right: #{e.msg} | err_code: #{e.status_code} | module_definition: #{module_name}"
            exit(e.status_code)
          end
          @modules << module_definition
        end
      end

      def yaml_parser
        YAML
      end

      def ruby_std_lib_module
        config_definition_std_lib = Archruby::Architecture::ConfigDefinition.new Archruby::Ruby::STD_LIB_NAME, {"gems"=>"", "files"=>"", "allowed"=>"", "forbidden" => ""}
        module_definiton_std_lib = Archruby::Architecture::ModuleDefinition.new(config_definition_std_lib, @base_path)
        module_definiton_std_lib.classes = Archruby::Ruby::STD_LIBRARY_CLASSES
        @modules << module_definiton_std_lib
      end

      def ruby_core_module
        config_definition_core = Archruby::Architecture::ConfigDefinition.new Archruby::Ruby::CORE_LIB_NAME, {"gems"=>"", "files"=>"", "allowed"=>"", "forbidden" => ""}
        module_definiton_core = Archruby::Architecture::ModuleDefinition.new(config_definition_core, @base_path)
        module_definiton_core.classes = Archruby::Ruby::CORE_LIBRARY_CLASSES
        @modules << module_definiton_core
      end

      def unknow_module
        config_definition_unknow = Archruby::Architecture::ConfigDefinition.new "unknown", {"gems"=>"unknown", "files"=>"", "allowed"=>"", "forbidden" => ""}
        @modules << Archruby::Architecture::ModuleDefinition.new(config_definition_unknow, @base_path)
      end

    end
  end
end
