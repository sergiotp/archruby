module Archruby
  module Architecture

    class TypeInferenceChecker
      attr_reader :method_and_deps, :method_calls

      def initialize(method_and_deps = nil, method_calls = nil)
        @method_and_deps = []
        @method_calls = []
        @method_and_deps = method_and_deps unless method_and_deps.nil?
        @method_calls = method_calls unless method_calls.nil?
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
        @method_and_deps.each do |dep|
          modules.each do |modl|
            if !dep[:class_name].nil? && modl.is_mine?(dep[:class_name])
              dep[:dep].each do |class_dep|
                modl.add_new_dep(dep[:class_name], class_dep)
              end
            end
          end
        end
      end

      def verify_types
        3.times do
          @method_calls.each do |method_call|
            if !method_call[:method_call_params].nil?
              method_call[:method_call_params].each do |param|
                if method_call[:method_arguments] && method_call[:method_arguments].include?(param)
                  param_position = method_call[:method_arguments].index param
                  if !param_position.nil?
                    @method_and_deps.each do |dep|
                      if dep[:class_name] == method_call[:class]
                        class_dep = dep[:dep][param_position]
                        if class_dep
                          new_dep = Archruby::Ruby::TypeInferenceDep.new(
                            :class_dep => class_dep.class_dep
                          )
                          add_method_deps([{
                            :class_name => method_call[:class_call],
                            :method_name => method_call[:method_call],
                            :dep => [new_dep] # tem que ser adicionado na posicao param_position
                          }])
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

    end
  end
end
