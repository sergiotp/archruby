module ArchChecker
  module Architecture
    
    class Architecture
      attr_reader :constraints_breaks, :modules
      
      def initialize modules
        @modules = modules
        @constraints_breaks = []
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
      
      def how_many_break module_name, constraint_type
        raise ArchitectureNotVerified if @constraints_breaks.empty?
        count = 0
        @constraints_breaks.each do |constraint_break|
          if constraint_break.type == constraint_type && constraint_break.module_origin == module_name
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
        module_name_to_return
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