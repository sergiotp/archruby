require 'yaml'

module ArchChecker
  module Architecture
    
    class Parser
      attr_reader :modules
      attr_reader :constraints
    
      def initialize config_file_path
        @config_file = config_file_path
        @modules = {}
        @constraints = {}
        parse
      end
      
      def parse
        parsed_yaml = yaml_parser.load_file @config_file 
        parse_modules parsed_yaml['modules']
        parse_constraints parsed_yaml['constraints']
      end
      
      private
    
      def parse_modules modules_definition
        modules_definition.each do |module_name, definitions|
          module_name = module_name.to_sym
          @modules[module_name] = {}
          @modules[module_name][:gems] = parse_gem definitions
          @modules[module_name][:files] = parse_files definitions
        end
      end
    
      def parse_constraints constraints_definitions
        constraints_definitions.each do |key, value| 
          key = key.to_sym
          @constraints[key] = value
        end
      end
    
      def parse_gem gem_definitions
        gem_definitions['gems']
      end
    
      def parse_files files_definitions
        files_definitions['files']
      end

      def yaml_parser
        YAML
      end

    end
  end
end
