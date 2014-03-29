module ArchChecker
  module Architecture

    class Architecture
      attr_reader :constraints_breaks, :modules, :unknown_module

      def initialize modules
        @modules = modules
        @constraints_breaks = []
        @unknown_module = @modules.select{ |module_definition| module_definition.name == "unknown" }.first
      end

      def verify
        @modules.each do |module_name|
          contraints_breaks = module_name.verify_constraints(self)
          if !contraints_breaks.empty?
            @constraints_breaks << contraints_breaks
          end
        end
        @constraints_breaks = @constraints_breaks.flatten
        @constraints_breaks
      end

      def how_many_break module_name, module_target, constraint_type
        raise ArchitectureNotVerified if @constraints_breaks.empty?
        count = 0
        @constraints_breaks.each do |constraint_break|
          if constraint_break.type == constraint_type && constraint_break.module_origin == module_name && constraint_break.module_target == module_target
            count += 1
          end
        end
        count
      end

      def module_name class_name
        module_name_to_return = ''
        @modules.each do |module_name|
          if module_name.is_mine? class_name
            module_name_to_return = module_name.name
            break
          end
        end
        if module_name_to_return.eql? ''
          @unknown_module.name
        else
          module_name_to_return
        end
      end

      def how_many_access_to module_origin, module_dest
        module_origin = search_module module_origin
        count = 0
        module_origin.dependencies.each do |dependency_class_name|
          dependency_module_name = module_name dependency_class_name
          if dependency_module_name == module_dest
            count += 1
          end
        end
        count
      end

      def is_ruby_internals? module_name
        module_name == ArchChecker::Ruby::STD_LIB_NAME || module_name == ArchChecker::Ruby::CORE_LIB_NAME
      end

    private

      def search_module module_name
        @modules.each do |module_definition|
          if module_definition.name == module_name
            return module_definition
          end
        end
      end

    end

  end
end
