module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class MethodDefinition
          attr_reader :class_name, :method_name, :args, :method_calls

          def initialize(class_name, method_name, args, method_calls)
            @class_name = class_name
            @method_name = method_name
            @args = args
            @method_calls = method_calls
          end
        end

      end
    end
  end
end
