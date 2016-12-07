module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class InternalMethodInvocation
          attr_reader :class_name, :method_name, :params, :linenum, :var_name

          def initialize(class_name, method_name, params=nil, linenum = nil, var_name=nil)
            @class_name = class_name
            @method_name = method_name
            @params = params
            @linenum = linenum
            @var_name = var_name
          end
        end

      end
    end
  end
end
