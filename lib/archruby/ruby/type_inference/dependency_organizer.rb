module Archruby
  module Ruby
    module TypeInference

      class DependencyOrganizer
        attr_reader :dependencies, :method_definitions

        def initialize
          @dependencies = {}
          @method_definitions = {}
        end

        def add_dependencies(found_dependencies)
          found_dependencies.each do |class_dependency|
            class_name = class_dependency.name
            @dependencies[class_name] ||= Set.new
            @dependencies[class_name].merge(class_dependency.dependencies)
          end
        end

        def add_method_calls(found_calls)          
          found_calls.each do |method_definition|
            next if unused_method_definition?(method_definition)
            method_name = method_definition.method_name
            class_name = method_definition.class_name
            args = method_definition.args
            internal_method_calls = []
            method_definition.method_calls.each do |internal_method_call|
              next if unused_internal_method_call?(internal_method_call)
              internal_method_calls << internal_method_call
            end
            if !internal_method_calls.empty?
              method_def = Ruby::MethodDefinition.new(class_name, method_name, args, internal_method_calls)
              @method_definitions[class_name] ||= []
              @method_definitions[class_name] << method_def
            end
          end
        end

        def read_from_csv_file
          require 'csv'
          new_dependencies = []
          CSV.foreach("information.csv") do |row|
            klass = row[0]
            klass.gsub!("#<Class:", "")
            klass.gsub!(">", "")
            method = row[1]
            size = row.size - 1
            class_dependency = Archruby::Ruby::TypeInference::Ruby::ClassDependency.new(klass)
            size.downto 0 do |pos|
              dependency = row[pos]
              dependency = dependency.split("|")
              if dependency.size > 1
                class_dep = dependency[1].strip
                if !class_dep.eql?("") && !Archruby::Ruby::CORE_LIBRARY_CLASSES.include?(class_dep)
                  class_dependency.add_dependency(class_dep)
                end
                break
              else
                class_dep = dependency[0].strip
                if !class_dep.eql?("") && !Archruby::Ruby::CORE_LIBRARY_CLASSES.include?(class_dep)
                  class_dependency.add_dependency(class_dep)
                end
              end
            end
            if class_dependency.dependencies.size > 0
              new_dependencies << class_dependency
            end
          end
          #binding.pry
          add_dependencies(new_dependencies)
        end

        def unused_method_definition?(method_definition)
          method_definition.method_calls.empty? || method_definition.class_name.to_s.empty?
        end

        def unused_internal_method_call?(internal_method_call)
          internal_method_call.params.nil?            ||
          internal_method_call.params.empty?          ||
          internal_method_call.class_name.to_s.empty?
        end
      end

    end
  end
end
