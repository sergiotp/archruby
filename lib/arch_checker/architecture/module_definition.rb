module ArchChecker
  module Architecture
    
    class ModuleDefinition
      
      ALLOWED_CONSTRAINTS = ['required', 'allowed', 'forbidden']
      
      attr_reader :name, :files, :gems, :allowed_modules, :required_modules, :forbidden_modules,
      :classes, :dependencies, :classes_and_dependencies
      
      def initialize module_name, definitions, base_directory
        @name = module_name
        @files = parse_files definitions['files']
        @gems = parse_gems definitions['gems']
        parse_constraints definitions
        @base_directory = base_directory
        @files_and_contents = []
        @classes = []
        @dependencies = []
        @classes_and_dependencies = []
        extract_content_of_files
        extract_dependencies        
      end
      
      def parse_files files
        files = '' if files.nil?
        files = files.split(',')
        normalize_string_spaces files
        files
      end
      
      def parse_gems gems
        gems = '' if gems.nil?
        gems = gems.split(',')
        normalize_string_spaces gems
        gems
      end
                        
      def parse_constraints definitions
        ALLOWED_CONSTRAINTS.each do |constraint|
          constraint_definition = definitions[constraint]
          constraint_definition = '' if constraint_definition.nil?
          send "#{constraint}_modules=", normalize_string_spaces(constraint_definition.split(','))
        end
      end
      
      def normalize_string_spaces array_of_strings
        array_of_strings.map! {|element| element.strip }
      end
      
      def extract_content_of_files file_extractor = ArchChecker::Architecture::FileContent
        file_extractor = file_extractor.new(@base_directory)
        files.each do |file|
          file_content = file_extractor.all_content_from_directory file
          @files_and_contents << file_content
        end
      end
      
      def extract_dependencies ruby_parser = ArchChecker::Ruby::Parser
        @files_and_contents.each do |file_and_content|
          file_and_content.each do |file_name, content|
            parser = ruby_parser.new content
            @classes << parser.classes
            @dependencies << parser.dependencies
            @classes_and_dependencies << parser.classes_and_dependencies
          end
        end
        @classes << @gems
        @classes.flatten!
        @dependencies.flatten!
      end
      
      def is_mine? class_name
        class_name = class_name.split('::').first
        @classes.each do |klass|
          #TODO Arrumar isso com uma expressao regular
          if klass.include?(class_name) && klass.size == class_name.size
            return true
          end
        end
        return false
      end
      
      def is_external?
        @files.empty?
      end
      
      def verify_constraints architecture
        required_breaks = verify_required architecture
        forbidden_breaks = verify_forbidden architecture
        allowed_breaks = verify_allowed architecture
        all_constraints_breaks = [required_breaks, forbidden_breaks, allowed_breaks].flatten
        all_constraints_breaks.delete(nil)
        all_constraints_breaks
      end
            
      def allowed_modules=(modules)
        @allowed_modules = modules
      end
      
      def required_modules=(modules)
        @required_modules = modules
      end
      
      def forbidden_modules=(modules)
        @forbidden_modules = modules
      end      
      
      # Verifica todas as classes do modulo
      # Cada uma deve, de alguma forma, depender dos modulos que estao listados como required
      def verify_required architecture
        return if @required_modules.empty?
        breaks = []
        @classes_and_dependencies.each_with_index do |class_and_depencies, index|
          if class_and_depencies.empty?
            breaks << ArchChecker::Architecture::ConstraintBreak.new(:type => 'absence', :module_origin => self.name, :module_target => @required_modules.first, :class_origin => @classes[index])  
            next
          end
          class_and_depencies.each do |class_name, dependencies|
            dependency_module_names = []
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              dependency_module_names << module_name
            end
            @required_modules.each do |required_module|
              if !dependency_module_names.include?(required_module)
                breaks << ArchChecker::Architecture::ConstraintBreak.new(:type => 'absence', :module_origin => self.name, :module_target => required_module, :class_origin => class_name)
              end
            end
          end
        end        
        breaks
      end

      def verify_forbidden architecture
        return if @forbidden_modules.empty?
        breaks = []
        @classes_and_dependencies.each do |class_and_depencies|
          class_and_depencies.each do |class_name, dependencies|
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              if @forbidden_modules.include? module_name
                breaks << ArchChecker::Architecture::ConstraintBreak.new(:type => 'divergence', :class_origin => class_name, :line_origin => dependency.line_number, :class_target => dependency.class_name, :module_origin => self.name, :module_target => module_name)
              end
            end
          end
        end
        breaks        
      end
      
      def verify_allowed architecture
        return if @allowed_modules.empty?
        breaks = []
        @classes_and_dependencies.each do |class_and_depencies|
          class_and_depencies.each do |class_name, dependencies|
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              if module_name != self.name && !@allowed_modules.include?(module_name)
                breaks << ArchChecker::Architecture::ConstraintBreak.new(:type => 'divergence', :class_origin => class_name, :line_origin => dependency.line_number, :class_target => dependency.class_name, :module_origin => self.name, :module_target => module_name)
              end
            end
          end
        end
        breaks
      end

private

    end
  end
end