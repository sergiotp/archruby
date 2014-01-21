module ArchChecker
  module Architecture    

    class FileDependencies
      def initialize src
        @src = src
      end
      
      def dependencies
        ruby_parser = ArchChecker::Ruby::Parser.new(@src)
        ruby_parser.parse
        ruby_parser.dependencies
      end
    end

  end
end