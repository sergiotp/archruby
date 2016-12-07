module Archruby
  module Ruby
    module TypeInference

      class TypeInferenceChecker
        attr_reader :dependencies, :method_definitions

        def initialize(dependencies, method_definitions)
          @dependencies = dependencies
          @method_definitions = method_definitions
        end

        def total_deps
          total_dep = 0
          @dependencies.each do |class_name, deps|
            total_dep += deps.size
          end
          total_dep
        end

        def print_method_definitions(base_path)
          file = File.open("#{base_path}/information_archmethods.csv", 'a')
          @method_definitions.each do |class_name, method_definitions|
            method_definitions.each do |method_def|
              classes = []
              var_names = []
              method_def.method_calls.each do |m_c|
                classes << m_c.class_name
                var_names << m_c.var_name
              end
              classes_args = []
              method_def.args.each do |key, value|
                classes_args << value.to_a
              end
              classes_args.flatten!
              file.puts "#{class_name}, #{method_def.method_name}, #{var_names.join(',')}, | #{classes.join(',')}"
              file.puts "#{class_name}, #{method_def.method_name}, | #{classes_args.join(',')}"
            end
          end
          file.close
        end

        def add_dependency_based_on_calls
          @method_definitions.each do |class_name, method_definitions|
            method_definitions.each do |method_definition|
              method_definition.method_calls.each do |method_call|
                receiver_class = method_call.class_name
                method_name = method_call.method_name
                dependencies = extract_param_classes(method_definition.args, method_call.params)
                add_new_dependencies(receiver_class, dependencies, method_name)
              end
            end
          end
        end

        def add_dependency_based_on_internal_calls
          3.times do
            @method_definitions.each do |class_name, method_definitions|
              method_definitions.each do |method_definition|
                method_definition.method_calls.each do |method_call|
                  receiver_class = method_call.class_name
                  method_name = method_call.method_name
                  formal_params = extract_formal_parameter(method_call.params)
                  dependencies = extract_param_classes(method_definition.args, formal_params)
                  add_new_dependencies(receiver_class, dependencies, method_name)
                end
              end
            end
          end
        end

        def extract_param_classes(method_args, params)
          dependencies = []
          params.each do |param|
            if param.class == Symbol
              type = method_args[param]
              type = type.to_a
              dependencies << type
            elsif param.class == String
              type = [param]
              dependencies << type
            end
          end
          dependencies
        end

        def extract_formal_parameter(params)
          formal_params = []
          params.each do |param|
            if param.class == Symbol
              formal_params << param
            end
          end
          formal_params
        end

        def add_new_dependencies(receiver_class, dependencies, method_name)
          add_to_dependencies(receiver_class, dependencies)
          add_to_method_definitions(receiver_class, dependencies, method_name)
        end

        def add_to_dependencies(receiver_class, dependencies)
          dep_class = @dependencies[receiver_class]
          if dep_class.nil?
            @dependencies[receiver_class] = Set.new
            dep_class = @dependencies[receiver_class]
          end
          # utilizamos o flatten pois aqui não importa a posição
          # do parametro formal
          dependencies.flatten.each do |dependency|
            dep_class.add(dependency)
          end
        end

        def add_to_method_definitions(receiver_class, dependencies, method_name)
          method_definitions = @method_definitions[receiver_class]
          if method_definitions
            method_definitions.each do |method_definition|
              if method_definition.method_name == method_name
                add_new_params_dependency(method_definition, dependencies)
                break
              end
            end
          end
        end

        def add_new_params_dependency(method_definition, dependencies)
          args = method_definition.args.keys
          dependencies.each_with_index do |deps, i|
            # aqui mantemos a ordem dos parametros formais
            formal_parameter_name = method_definition.args[args[i]]
            if formal_parameter_name
              deps.each do |dep|
                begin
                  formal_parameter_name.add(dep)
                rescue
                  binding.pry
                end
              end
            end
          end
        end

      end

    end
  end
end
