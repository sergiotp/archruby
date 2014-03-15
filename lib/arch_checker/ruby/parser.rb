require 'ruby_parser'
require 'sexp_processor'

module ArchChecker
  module Ruby
    
    class Parser < SexpInterpreter
      attr_reader :dependencies, :classes, :classes_and_dependencies
      
      def initialize content
        super()
        @content = content
        @dependencies = []
        @classes = []
        @full_class_path = []
        @classes_and_dependencies = {}
        @complete_class_name = []
        parse
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
        if class_name.class == Symbol
          @classes << class_name.to_s
        else
          get_complete_class_name class_name
          @classes << @complete_class_name.join("::")
        end
        args.map! {|sub_tree| process sub_tree}
      end
      
      def get_complete_class_name exp
        if exp[0] == :const
          _, const_name = exp
          @complete_class_name.unshift const_name
          return
        else
          _, first_part, last_constant_part = exp
          @complete_class_name.unshift(last_constant_part)
          get_complete_class_name first_part
        end        
      end
      
      def process_const exp
        _, const_name = exp
        if !@full_class_path.empty?
          const_name = build_full_name(const_name)
        end
        @dependencies << const_name.to_s
        build_class_dependency const_name, exp.line
      end
      
      def build_full_name const_name
        @full_class_path.unshift const_name
        full_class_path = @full_class_path.join('::')
        @full_class_path = []
        full_class_path
      end
      
      def build_class_dependency const_name, line_number
        return if @classes.empty?
        class_name = @classes.last
        @classes_and_dependencies[class_name] = [] if @classes_and_dependencies[class_name].nil?
        @classes_and_dependencies[class_name] << ArchChecker::Architecture::Dependency.new(const_name, line_number)
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
        @full_class_path.unshift(last_part)
        process first_part
      end
      
      def process_hash exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_iasgn exp
        _, variable_name, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_defs exp
        _, receiver, method_name, arguments, *args = exp
        process arguments
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_attrasgn exp
        _, object, method_call, *args = exp
        process object
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_ivar exp
        _, instance_variable_name = exp
      end
            
      def process_dstr exp
        _, string, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_evstr exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_self exp
        _ = exp        
      end
      
      def process_masgn exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_array exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_cdecl exp
        _, constant_name = exp
      end
      
      def process_and exp        
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_colon3 exp
        _, constant_name = exp
      end
      
      def process_rescue exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_resbody exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_gvar exp
        _, ruby_global_var_name = exp
      end
      
      def process_if exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_true exp
        _ = exp
      end
      
      def process_false exp
        _ = exp
      end
      
      def process_case exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_when exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_op_asgn1 exp
        _, variabe_rec, position_to_access, operator, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_arglist exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_block_pass exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_or exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_sclass exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_next exp
        _ = exp
      end
      
      def process_module exp
        _, module_name, *args = exp
        @classes << module_name.to_s
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_to_ary exp
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end
      
      def process_while exp
        _, condition, *args = exp
        true_clause = args.pop
        args.map! {|sub_tree| process sub_tree}
      end
      
      def ruby_parser
        RubyParser.new
      end
    end
    
  end
end