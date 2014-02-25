require 'yaml'

module ArchChecker
  module Architecture
    
    class Parser
      attr_reader :modules
    
      def initialize config_file_path, base_path
        @config_file = config_file_path
        @base_path = base_path
        @modules = []
        parse
      end
      
      def parse
        parsed_yaml = yaml_parser.load_file @config_file
        parsed_yaml.each do |module_name, definitions|
          begin
            module_definition = ArchChecker::Architecture::ModuleDefinition.new(module_name, definitions, @base_path)
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

    end
  end
end
