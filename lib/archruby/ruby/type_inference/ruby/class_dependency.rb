module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class ClassDependency
          attr_reader :dependencies, :name

          def initialize(name)
            @name = name
            @dependencies = Set.new
          end

          def add_dependency(class_name)
            @dependencies.add(class_name)
          end
        end

      end
    end
  end
end
