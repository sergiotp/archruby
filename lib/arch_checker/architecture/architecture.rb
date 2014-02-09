module ArchChecker
  module Architecture
    
    class Architecture
      attr_reader :constraints_breaks
      
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
      
    end
  
  end
end