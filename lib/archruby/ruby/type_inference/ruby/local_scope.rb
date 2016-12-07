module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class LocalScope
          def initialize
            @scopes = [Set.new]
            @formal_parameters = [Set.new]
            @current_scope = @scopes.last
            @current_formal_parameters = @formal_parameters.last
          end

          def add_variable(name, type)
            @current_scope.add([name, type])
          end

          def add_formal_parameter(name, type)
            @current_formal_parameters.add([name, type])
          end

          def var_type(name)
            @current_scope.each do |var_info|
              if var_info[0].to_s == name.to_s
                return var_info[1]
              end
            end
            return nil
          end

          def has_formal_parameter(name)
            check_from_collection(@current_formal_parameters, name)
          end

          def has_local_params(name)
            check_from_collection(@current_scope, name)
          end

          def add_new_scope
            @scopes << Set.new
            @current_scope = @scopes.last
            @formal_parameters << Set.new
            @current_formal_parameters = @formal_parameters.last
          end

          def remove_scope
            @scopes.pop
            @current_scope = @scopes.last
            @formal_parameters.pop
            @current_formal_parameters = @formal_parameters.last
          end

          private

          def check_from_collection(collection, name)
            collection.each do |var_info|
              if var_info[0].to_s == name.to_s
                return true
              end
            end
            return false
          end
        end

      end
    end
  end
end
