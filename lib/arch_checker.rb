require "arch_checker/version"

require 'arch_checker/architecture/parser'
require 'arch_checker/ruby/parser'
require 'arch_checker/architecture/file_content'
require 'arch_checker/architecture/file_dependencies'

module ArchChecker
  class ExtractArchitecture
    def initialize config_file_path = "", base_directory = ""
      @config_file_path = config_file_path
      @base_directory = base_directory
      @architecture_definition = ArchChecker::Architecture::Parser.new(File.expand_path(@config_file_path, __FILE__))
    end
    
    def extract_classes_and_dependencies
      content_of_files = extract_content_files
      dependencies = []
      content_of_files.each do |module_files|
        module_dependencies = {} 
        module_dependencies[module_files.first[0]] = {}
        module_dependencies[module_files.first[0]][:classes] = []
        module_dependencies[module_files.first[0]][:dependencies] = []
        if module_files.first[1].eql?({})
          gem_dependency = @architecture_definition.modules[module_files.first[0]][:gems]
          module_dependencies[module_files.first[0]][:classes] << gem_dependency
        end
        module_files.first[1].each do |file, content|
          ruby_parser = ArchChecker::Ruby::Parser.new(content)
          file_dependencies = ruby_parser.dependencies
          module_dependencies[module_files.first[0]][file] = file_dependencies
          module_dependencies[module_files.first[0]][:dependencies] << file_dependencies
          module_dependencies[module_files.first[0]][:classes] << ruby_parser.classes
          module_dependencies[module_files.first[0]][:classes].flatten!
          module_dependencies[module_files.first[0]][:dependencies].flatten!
        end
        dependencies << module_dependencies
      end
      dependencies
    end
    
    def extract_content_files
      content_of_files = []
      file_content_extractor = ArchChecker::Architecture::FileContent.new(@base_directory)
      @architecture_definition.modules.each do |module_name, module_definition|
        files = module_definition[:files]
        file_content = file_content_extractor.all_content_from_directory(files)
        file_content = file_content.nil? ? {} : file_content
        content_of_files << { module_name.to_sym => file_content }
      end
      content_of_files      
    end
          
    def check_constraints dependencies = nil
      constraint_breaks = []
      architecture_constraints = @architecture_definition.constraints
      architecture_constraints[:only].each do |only_constraints|
        constraint_breaks << check_only_constraint(only_constraints, dependencies)
      end
      architecture_constraints.each do |architecture_contraint|
        next if architecture_contraint[0] == :only
        constraint_breaks << check_module_constraint(architecture_contraint, dependencies)
      end
      puts constraint_breaks.inspect
      generate_txt constraint_breaks
      
    end
    
    def check_only_constraint only_constraint, dependencies
      constraints_breaks = []
      module_name = only_constraint[0]
      constraint = only_constraint[1]
      can_depend_module = constraint['can_depend']
      dependencies.each do |module_dependency|
        module_dependency_name = module_dependency.keys.first
        next if module_dependency_name.to_s == module_name.to_s
        module_dependency_definitons = module_dependency[module_dependency_name]
        module_class_dependencies = module_dependency_definitons[:dependencies]
        can_depend_module_definitions = extract_module_definitions can_depend_module, dependencies
        can_depend_module_classes = can_depend_module_definitions[:classes]
        module_class_dependencies.each do |class_dependency|
          if can_depend_module_classes.include? class_dependency
            constraints_breaks << {module_dependency_name => "depend #{can_depend_module}"}
          end
        end
      end
      constraints_breaks
    end
    
    def check_module_constraint module_architecture_constraint, dependencies
      constraints_breaks = []
      module_name = module_architecture_constraint[0]
      constraint = module_architecture_constraint[1]
      canot_depend_module = constraint['cannot_depend']
      puts module_name
      puts constraint
      puts canot_depend_module
      module_definitions = extract_module_definitions module_name, dependencies
      canot_depend_module_definitions = extract_module_definitions canot_depend_module, dependencies
      module_definitions[:dependencies].each do |class_dependency_name|
        if canot_depend_module_definitions[:classes].include? class_dependency_name
          constraints_breaks << {module_name => "depend #{canot_depend_module}"}
        end
      end
      puts canot_depend_module_definitions.inspect
      puts module_architecture_constraint.inspect
      constraints_breaks
    end
    
    def generate_txt constraint_breaks
      file = File.new('violations.txt', 'w')
      constraint_breaks.each do |constraint_break|
        constraint_break.each do |violations|
          file.puts "#{violations.keys.first} #{violations[violations.keys.first]}"
        end
      end
      
    end
    
    def extract_module_definitions module_name, dependencies
      module_definitions = nil
      dependencies.each do |module_dependency|
        if module_dependency.keys.first.to_s == module_name.to_s
          module_definitions = module_dependency[module_dependency.keys.first]
          break
        end
      end
      module_definitions
    end

  end
end

