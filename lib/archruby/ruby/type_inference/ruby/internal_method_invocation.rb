module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class InternalMethodInvocation
          attr_reader :class_name, :method_name, :params, :linenum

          def initialize(class_name, method_name, params=nil, linenum = nil)
            @class_name = class_name
            @method_name = method_name
            @params = params
            @linenum = linenum
          end
        end

      end
    end
  end
end
