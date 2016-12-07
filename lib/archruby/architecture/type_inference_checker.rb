module Archruby
  module Architecture

    class TypeInferenceChecker
      #attr_reader :method_and_deps, :method_calls
      attr_reader :dependencies

      def initialize(dependencies=nil)
        @dependencies = dependencies
        # @method_and_deps = []
        # @method_calls = []
        # @method_and_deps = method_and_deps unless method_and_deps.nil?
        # @method_calls = method_calls unless method_calls.nil?
      end

      def populate_dependencies(dependencies)
        @dependencies = dependencies
      end

      def add_method_deps(method_deps)
        @method_and_deps << method_deps
        @method_and_deps.flatten!
      end

      def add_method_calls(method_calls)
        @method_calls << method_calls
        @method_calls.flatten!
      end

      def add_new_deps(modules)
        @dependencies.each do |klass, dependencies|
          modules.each do |modl|
            if !klass.nil? && modl.is_mine?(klass)
              dependencies.each do |class_dep_name|
                modl.add_new_dep(klass, class_dep_name)
              end
            end
          end
        end
        # @method_and_deps.each do |dep|
        #   modules.each do |modl|
        #     if !dep[:class_name].nil? && modl.is_mine?(dep[:class_name])
        #       dep[:dep].each do |class_dep|
        #         modl.add_new_dep(dep[:class_name], class_dep)
        #         binding.pry
        #       end
        #     end
        #   end
        # end
      end

    end
  end
end
