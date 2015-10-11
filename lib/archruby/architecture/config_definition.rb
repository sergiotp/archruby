module Archruby
  module Architecture

    class ConfigDefinition

      ALLOWED_CONSTRAINTS = ['required', 'allowed', 'forbidden']

      attr_reader :module_name, :files, :gems, :allowed_modules, :required_modules, :forbidden_modules

      def initialize(module_name, definitions)
        @module_name = module_name
        @files = parse_files(definitions['files'])
        @gems = parse_gems(definitions['gems'])
        parse_constraints(definitions)
      end

      def parse_files(files)
        files = '' if files.nil?
        files = files.split(',')
        normalize_string_spaces(files)
        files
      end

      def parse_gems(gems)
        gems = '' if gems.nil?
        gems = gems.split(',')
        normalize_string_spaces(gems)
        gems
      end

      def parse_constraints(definitions)
        check_constraints(definitions)
        ALLOWED_CONSTRAINTS.each do |constraint|
          constraint_definition = definitions[constraint]
          constraint_definition = '' if constraint_definition.nil?
          send("#{constraint}_modules=", normalize_string_spaces(constraint_definition.split(',')))
        end
      end

      def normalize_string_spaces(array_of_strings)
        array_of_strings.map! {|element| element.strip }
      end

      def allowed_modules=(modules)
        @allowed_modules = modules
      end

      def required_modules=(modules)
        @required_modules = modules
      end

      def forbidden_modules=(modules)
        @forbidden_modules = modules
      end

    private

      def check_constraints(definitions)
        raise MultipleConstraints if definitions['allowed'] && !definitions['allowed'].empty? && definitions['forbidden'] && !definitions['forbidden'].empty?
      end


    end

  end
end
