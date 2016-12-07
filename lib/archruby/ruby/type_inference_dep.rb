module Archruby
  module Ruby
    class TypeInferenceDep

      attr_reader :class_source, :class_dep, :line_source_num

      def initialize options
        @class_source = options[:class_source]
        @class_dep = options[:class_dep]
        @line_source_num = options[:line_source_num]
      end
    end
  end
end
