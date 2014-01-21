require "arch_checker/version"

require 'arch_checker/architecture/parser'
require 'arch_checker/ruby/parser'
require 'arch_checker/architecture/file_content'
require 'arch_checker/architecture/file_dependencies'

module ArchChecker
  class ExtractArchitecture
    def initialize config_file_path = "", base_directory = ""
      @architecture_definition = ArchChecker::Architecture::Parser.new(File.expand_path('../../spec/fixtures/arch_definition.yml', __FILE__))
      parse_config_file
    end

    def parse_config_file
      @architecture_definition.parse
    end
    
    def extract_classes_and_dependencies
      content_of_files = extract_content_files
      dependencies = []
      content_of_files.each do |module_files|
        module_dependencies = {} 
        module_files.first[1].each do |file, content|
          module_dependencies[module_files.first[0]] = {}
          module_dependencies[module_files.first[0]][:classes] = []
          ruby_parser = ArchChecker::Ruby::Parser.new(content)
          module_dependencies[module_files.first[0]][file] = ruby_parser.dependencies
          module_dependencies[module_files.first[0]][:classes] = ruby_parser.classes
        end
        dependencies << module_dependencies
      end
      dependencies
    end
    
    def extract_content_files
      content_of_files = []
      file_content_extractor = ArchChecker::Architecture::FileContent.new("/Users/sergiomiranda/Labs/ruby_arch_checker/arch_checker/spec/dummy_app/")
      @architecture_definition.modules.each do |module_name, module_definition|
        files = module_definition[:files]        
        content_of_files << { module_name.to_sym => file_content_extractor.all_content_from_directory(files) }
      end
      content_of_files
    end
          
    def check_violations
      
    end
  end
end

