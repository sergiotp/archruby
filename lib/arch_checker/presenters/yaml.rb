require 'yaml'

module ArchChecker
  module Presenters
   
    class Yaml
      def render constraint_breaks
        contraints = []
        constraint_breaks.each do |constraint_break|
          constraint = {}
          constraint[constraint_break.type] = {}
          constraint[constraint_break.type]['class_origin'] = constraint_break.class_origin
          constraint[constraint_break.type]['line_origin'] = constraint_break.line_origin
          constraint[constraint_break.type]['class_target'] = constraint_break.class_target
          constraint[constraint_break.type]['module_origin'] = constraint_break.module_origin
          constraint[constraint_break.type]['module_target'] = constraint_break.module_target
          contraints << constraint
        end
        contraints.to_yaml
      end
    end

  end
end