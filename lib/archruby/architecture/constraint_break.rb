module Archruby
  module Architecture
    class ConstraintBreak
      attr_reader :type, :class_origin, :line_origin, :class_target, :module_origin,
      :module_target, :msg

      ABSENSE = "absence"
      DIVERGENCE = "divergence"

      def initialize(options)
        @type = options[:type]
        @class_origin = options[:class_origin]
        @line_origin = options[:line_origin]
        @class_target = options[:class_target]
        @module_origin = options[:module_origin]
        @module_target = options[:module_target]
        @msg = options[:msg]
      end

    end
  end
end
