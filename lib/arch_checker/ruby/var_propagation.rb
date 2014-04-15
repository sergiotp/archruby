module ArchChecker
  module Ruby
    class VarPropagation
      attr_reader :vars

      def initialize
        @vars = []
      end

      def push var_name, line_number, type = nil
        var = find_var var_name
        if var
          lines = var[var.keys.first][:lines]
          lines.push(line_number)
        else
          @vars.push(
            {
              var_name =>
                {
                  :lines => [line_number],
                  :type => type
                }
            }
          )
        end
      end

      def put_type var_name, type
        var = find_var var_name
        if var
          var[var.keys.first][:type] = type
        end
      end

      def find_var var_name
        vars.each do | var |
          if var.keys.first == var_name
            return var
          end
        end
        return nil
      end

    end
  end
end
