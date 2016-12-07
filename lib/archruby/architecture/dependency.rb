module Archruby
  module Architecture
    class Dependency
      attr_reader :class_name, :line_number

      def initialize(class_name, line_number)
        @class_name = class_name.to_s
        @line_number = line_number
      end

    end
  end
end
