require 'ruby_parser'
require 'sexp_processor'

module ArchChecker
  module Ruby
    
    class Parser < SexpInterpreter
      attr_reader :dependencies
      
      def initialize content
        super()
        @content = content
        @dependencies = []
      end
      
      def parse
        process ruby_parser.parse @content
      end
      
      def process_block exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_class exp
        _, class_name, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_const exp
        _, const_name = exp
        @dependencies << const_name.to_s
      end
      
      def process_call exp
        _, receiver, method_name, *args = exp
        process receiver
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_defn exp
        _, method_name, method_arguments, *args = exp
        process method_arguments
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_lasgn exp
        _, variable_name, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_lit exp
        _, value = exp
      end
      
      def process_lvar exp
        _, variable_name = exp
      end
      
      def process_iter exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_args exp
        _, *args = exp
        args.map! do |sub_tree| 
          process sub_tree if sub_tree.class != Symbol
        end
      end
      
      def process_nil exp
        _ = exp     
      end
      
      def process_str exp
        _, string = exp
      end
      
      def process_return exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_colon2 exp
        _, first_part, last_part = exp
        # falta pegar o full name da classe que tem dependencia
        process first_part
      end
      
      def process_hash exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
            
      def ruby_parser
        RubyParser.new
      end
    end
    
  end
end