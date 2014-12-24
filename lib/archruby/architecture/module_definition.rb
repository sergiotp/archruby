module Archruby
  module Architecture

    class ModuleDefinition

      ALLOWED_CONSTRAINTS = ['required', 'allowed', 'forbidden']

      attr_reader :name, :allowed_modules, :required_modules, :forbidden_modules,
      :dependencies, :classes_and_dependencies, :class_methods_and_deps,
      :class_methods_calls

      attr_accessor :classes

      def initialize config_definition, base_directory
        @config_definition = config_definition
        @name = @config_definition.module_name
        @allowed_modules = @config_definition.allowed_modules
        @required_modules = @config_definition.required_modules
        @forbidden_modules = @config_definition.forbidden_modules
        @base_directory = base_directory
        @files_and_contents = []
        @classes = []
        @dependencies = []
        @classes_and_dependencies = []
        @class_methods_and_deps = []
        @class_methods_calls = []
        extract_content_of_files
        extract_dependencies
      end

      def extract_content_of_files file_extractor = Archruby::Architecture::FileContent
        return if !@classes.empty?
        file_extractor = file_extractor.new(@base_directory)
        @config_definition.files.each do |file|
          file_content = file_extractor.all_content_from_directory file
          @files_and_contents << file_content
        end
      end

      def extract_dependencies ruby_parser = Archruby::Ruby::Parser
        return if !@classes.empty?
        @files_and_contents.each do |file_and_content|
          file_and_content.each do |file_name, content|
            parser = ruby_parser.new content
            @classes << parser.classes
            @dependencies << parser.dependencies
            @classes_and_dependencies << parser.classes_and_dependencies
            @class_methods_and_deps << parser.type_inference
            @class_methods_calls << parser.method_calls
          end
        end
        @classes << @config_definition.gems
        @classes.flatten!
        @dependencies.flatten!
        @class_methods_and_deps.flatten!
        @class_methods_calls.flatten!
      end

      def add_new_dep class_name, type_inference_dep
        if !type_inference_dep.class_dep.nil? && !already_has_dependency?(class_name, type_inference_dep.class_dep)
          new_dep = Archruby::Architecture::Dependency.new(type_inference_dep.class_dep, nil)
          @dependencies << type_inference_dep.class_dep
          @classes_and_dependencies.each do |class_and_dep|
            if class_and_dep.keys.first.eql?(class_name)
              class_and_dep[class_and_dep.keys.first].push(new_dep)
            end
          end
        end
      end

      def already_has_dependency? class_name, class_dep
        has_dep = false
        @classes_and_dependencies.each do |class_and_dep|
          if class_and_dep.keys.first.eql?(class_name)
            class_and_dep[class_and_dep.keys.first].each do |dependency|
              if dependency.class_name.eql?(class_dep)
                has_dep = true
                break
              end
            end
          end
        end
        has_dep
      end

      def is_mine? class_name
        splited_class_name = class_name.split('::')
        first_class_name = splited_class_name.first
        is_mine = false
        if first_class_name.empty?
          #pocurando por um match exato de dependencia
          first_name = splited_class_name[1]
          splited_class_name.shift # retirando o elemento ''
          class_name = splited_class_name.join("::")
          @classes.each do |klass|
            #TODO Arrumar isso com uma expressao regular
            if klass.include?(class_name) && klass.size == class_name.size
              is_mine = true
              break
            end
          end
          if !is_mine && !@config_definition.gems.empty?
            @classes.each do |klass|
              #TODO Arrumar isso com uma expressao regular
              if klass.include?(first_name) && klass.size == first_name.size
                is_mine = true
                break
              end
            end
          end
        end
        if !is_mine
          # procurando por acesso a classe que possa ser desse modulo
          class_name = splited_class_name.join("::")
          included_separator = class_name.include?("::")
          @classes.each do |klass|
            #TODO Arrumar isso com uma expressao regular
            if included_separator
              if klass.include?(class_name)
                is_mine = true
                break
              end
            else
              if klass.include?(class_name) && klass.size == class_name.size
                is_mine = true
                break
              end
            end
          end
        end
        if !is_mine
          # procurando por GEM
          @classes.each do |klass|
            #TODO Arrumar isso com uma expressao regular
            if klass.include?(first_class_name) && klass.size == first_class_name.size
              is_mine = true
              break
            end
          end
        end

        return is_mine
      end

      def is_external?
        !@config_definition.gems.empty?
      end

      def is_empty?
        @classes.empty?
      end

      def verify_constraints architecture
        required_breaks = verify_required architecture
        forbidden_breaks = verify_forbidden architecture
        allowed_breaks = verify_allowed architecture
        all_constraints_breaks = [required_breaks, forbidden_breaks, allowed_breaks].flatten
        all_constraints_breaks.delete(nil)
        all_constraints_breaks
      end

      # Verifica todas as classes do modulo
      # Cada uma deve, de alguma forma, depender dos modulos que estao listados como required
      def verify_required architecture
        return if @config_definition.required_modules.empty?
        breaks = []
        @classes_and_dependencies.each_with_index do |class_and_depencies, index|
          if class_and_depencies.empty?
            breaks << Archruby::Architecture::ConstraintBreak.new(
              :type => 'absence',
              :module_origin => self.name,
              :module_target => @config_definition.required_modules.first,
              :class_origin => @classes[index],
              :msg => "not implement a required module"
            )
            next
          end
          class_and_depencies.each do |class_name, dependencies|
            dependency_module_names = []
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              dependency_module_names << module_name
            end
            @config_definition.required_modules.each do |required_module|
              if !dependency_module_names.include?(required_module)
                breaks << Archruby::Architecture::ConstraintBreak.new(
                  :type => 'absence',
                  :module_origin => self.name,
                  :module_target => required_module,
                  :class_origin => class_name,
                  :msg => "not implement a required module"
                )
              end
            end
          end
        end
        breaks
      end

      def verify_forbidden architecture
        return if @config_definition.forbidden_modules.empty?
        breaks = []
        @classes_and_dependencies.each do |class_and_depencies|
          class_and_depencies.each do |class_name, dependencies|
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              next if architecture.is_ruby_internals? module_name
              if @config_definition.forbidden_modules.include? module_name
                next if /[A-Z]_+[A-Z]/.match(dependency.class_name)
                breaks << Archruby::Architecture::ConstraintBreak.new(
                  :type => 'divergence',
                  :class_origin => class_name,
                  :line_origin => dependency.line_number,
                  :class_target => dependency.class_name,
                  :module_origin => self.name,
                  :module_target => module_name,
                  :msg => "accessing a module which is forbidden")
              end
            end
          end
        end
        breaks
      end

      def verify_allowed architecture
        return if @config_definition.allowed_modules.empty?
        breaks = []
        @classes_and_dependencies.each do |class_and_depencies|
          class_and_depencies.each do |class_name, dependencies|
            dependencies.each do |dependency|
              module_name = architecture.module_name(dependency.class_name)
              next if architecture.is_ruby_internals? module_name
              if module_name != self.name && !@config_definition.allowed_modules.include?(module_name)
                next if /[A-Z]_+[A-Z]/.match(dependency.class_name) || @config_definition.required_modules.include?(module_name)
                breaks << Archruby::Architecture::ConstraintBreak.new(
                  :type => 'divergence',
                  :class_origin => class_name,
                  :line_origin => dependency.line_number,
                  :class_target => dependency.class_name,
                  :module_origin => self.name,
                  :module_target => module_name,
                  :msg => "module #{self.name} is not allowed to depend on module #{module_name}")
              end
            end
          end
        end
        breaks
      end

    end
  end
end
