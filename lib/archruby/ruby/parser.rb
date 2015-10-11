require 'ruby_parser'
require 'sexp_processor'

module Archruby
  module Ruby

    class Parser < SexpInterpreter
      attr_reader :dependencies, :classes, :classes_and_dependencies,
                  :type_inference, :method_calls, :type_propagation_parser

      def initialize(content)
        super()
        #a = Archruby::Presenters::Graph.new
        @content = content
        @dependencies = []
        @classes = []
        @full_class_path = []
        @classes_and_dependencies = {}
        @module_names = []
        @complete_class_name = []
        @var_propagation = Archruby::Ruby::VarPropagation.new
        @type_propagation_parser = Archruby::Ruby::TypeInference::Ruby::ParserForTypeinference.new
        @type_inference = []
        @method_calls = []
        parse
      end

      def parse
        process ruby_parser.parse(@content)
        @type_propagation_parser.parse(@content)
      end

      def process_block(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_class(exp)
        _, class_name, *args = exp
        if class_name.class == Symbol
          if !@module_names.empty?
            @classes << "#{@module_names.join("::")}::#{class_name}"
          else
            @classes << class_name.to_s
          end
        else
          # cai aqui quando a definicao é algo do tipo: class Teste::De end
          get_complete_class_name(class_name)
          @classes << @complete_class_name.join("::")
          @complete_class_name = []
        end
        args.map! {|sub_tree| process(sub_tree)}
      end

      def get_complete_class_name(exp)
        if exp[0] == :const
          _, const_name = exp
          @complete_class_name.unshift(const_name)
          return
        else
          _, first_part, last_constant_part = exp
          @complete_class_name.unshift(last_constant_part)
          get_complete_class_name first_part
        end
      end

      def process_const(exp)
        _, const_name = exp
        if !@full_class_path.empty?
          const_name = build_full_name(const_name)
        end
        add_dependency(const_name)
        build_class_dependency(const_name, exp.line)
      end

      def build_full_name(const_name)
        @full_class_path.unshift(const_name)
        full_class_path = @full_class_path.join('::')
        @full_class_path = []
        full_class_path
      end

      def build_class_dependency(const_name, line_number)
        return if @classes.empty?
        class_name = @classes.last
        @classes_and_dependencies[class_name] = [] if @classes_and_dependencies[class_name].nil?
        @classes_and_dependencies[class_name] << Archruby::Architecture::Dependency.new(const_name, line_number)
      end

      def add_dependency(const_name)
        @dependencies << const_name.to_s if !@dependencies.include?(const_name.to_s)
      end

      def process_colon3(exp)
        _, constant_name = exp
        const_name = build_full_name("::#{constant_name}")
        add_dependency(const_name)
        build_class_dependency(const_name, exp.line)
      end

      def process_call(exp)
        _, receiver, method_name, *args = exp
        process(receiver)
        if receiver && (receiver[0] == :const || receiver[0] == :colon2)
          if @variables
            @var_propagation.push(@variables.last, exp.line, @dependencies.last)
          end
        end
        build_type_inference(receiver, method_name, args, exp.line)
        args.map! {|sub_tree| process sub_tree}
      end

      def build_call_history(receiver, method_name, params_name)
        @method_calls << {
          :class => @classes.last,
          :method => @current_method_name,
          :method_arguments => @current_arguments,
          :class_call => receiver,
          :method_call => method_name,
          :method_call_params => params_name
        }
      end

      def build_type_inference(receiver, method_name, params, line_num)
        if !@local_types.nil? && receiver && receiver[0] == :lvar
          receiver = @local_types[receiver[1]]
          params_name = []
          deps = []
          params.each do |param|
            if param[0] == :lvar
              params_name << param[1]
              type_inference = TypeInferenceDep.new(
                :class_source => @classes.last,
                :class_dep => @local_types[param[1]],
                :line_source_num => line_num
              )
              deps << type_inference
            elsif param[0] == :call
              process param
              type_inference = TypeInferenceDep.new(
                :class_source => @classes.last,
                :class_dep => @dependencies.last,
                :line_source_num => line_num
              )
              deps << type_inference
            end
          end
          build_call_history(receiver, method_name, params_name)
          @type_inference << {
            :class_name => receiver,
            :method_name => method_name,
            :dep => deps
          } if deps.size >= 1
        end
      end

      def extract_arguments(arguments)
        _, *arg_vars = arguments
        if arg_vars[0].class == Symbol
          @current_arguments = arg_vars
        end
      end

      def process_defn(exp)
        @variables = []
        @local_types = {}
        _, method_name, method_arguments, *args = exp
        @current_method_name = method_name
        extract_arguments(method_arguments)
        process(method_arguments)
        args.map! {|sub_tree| process sub_tree}
        @var_propagation.vars.each do |var|
          var = var[var.keys.first]
          if var[:type]
            var[:lines].shift
            var[:lines].each do |line_number|
              build_class_dependency(var[:type], line_number)
            end
          end
        end
        @var_propagation = Archruby::Ruby::VarPropagation.new
        @variables = []
        @current_method_name = nil
        @current_arguments = nil
      end

      def process_lasgn(exp)
        _, variable_name, *args = exp
        const_access = args[0][0] == :call unless args[0].nil?
        @variables.push(variable_name) if @variables
        args.map!{ |sub_tree| process(sub_tree) }
        if @local_types.class == Hash && const_access
          @local_types[variable_name] = @dependencies.last
        end
      end

      def process_lit(exp)
        _, value = exp
      end

      def process_lvar(exp)
        _, variable_name = exp
        @var_propagation.push(variable_name, exp.line)
      end

      def process_iter(exp)
        _, *args = exp
        args.map! {|sub_tree| next if sub_tree.class == Fixnum; process(sub_tree)}
      end

      def process_args(exp)
        _, *args = exp
        args.map! do |sub_tree|
          process sub_tree if sub_tree.class != Symbol
        end
      end

      def process_nil(exp)
        _ = exp
      end

      def process_str(exp)
        _, string = exp
      end

      def process_return(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree) }
      end

      def process_colon2(exp)
        _, first_part, last_part = exp
        @full_class_path.unshift(last_part)
        process(first_part)
      end

      def process_hash(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_iasgn exp
        _, variable_name, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_defs(exp)
        _, receiver, method_name, arguments, *args = exp
        process(arguments)
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_attrasgn(exp)
        _, object, method_call, *args = exp
        process(object)
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_ivar(exp)
        _, instance_variable_name = exp
      end

      def process_dstr(exp)
        _, string, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_evstr(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_self(exp)
        _ = exp
      end

      def process_masgn(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_array(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_cdecl(exp)
        _, constant_name = exp
      end

      def process_and(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_rescue(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_resbody(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_gvar(exp)
        _, ruby_global_var_name = exp
      end

      def process_if(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_true(exp)
        _ = exp
      end

      def process_false(exp)
        _ = exp
      end

      def process_case(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_when(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_op_asgn1(exp)
        _, variabe_rec, position_to_access, operator, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_arglist(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_block_pass(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_or(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_sclass(exp)
        _, *args = exp
        args.map! {|sub_tree| process sub_tree}
      end

      def process_next(exp)
        _ = exp
      end

      def process_module(exp)
        _, module_name, *args = exp
        if module_name.class == Symbol
          @module_names.push(module_name.to_s)
          @classes << @module_names.join('::')
        else
          get_complete_class_name(module_name)
          @classes << @complete_class_name.join('::')
          @module_names.push @complete_class_name.join('::')
          @complete_class_name = []
        end
        args.map! {|sub_tree| process(sub_tree)}
        @module_names.pop
      end

      def process_to_ary(exp)
        _, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_while(exp)
        _, condition, *args = exp
        true_clause = args.pop
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_cvdecl(exp)
        _, variable_name, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_cvar(exp)
        _, variable_name = exp
      end

      def process_until(exp)
        _, condition, *args = exp
        true_clause = args.pop
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_yield(exp)
        _, *body = exp
        if !body.empty?
          body.map! {|sub_tree| process(sub_tree)}
        end
      end

      def process_dot2(exp)
        _, first, second = exp
      end

      def process_zsuper(exp)
        _ = exp
      end

      def process_op_asgn_or(exp)
        _, first, second = exp
        process(first)
        process(second)
      end

      def process_match3(exp)
        _, regular_expression, *args = exp
        args.map! {|sub_tree| process(sub_tree)}
      end

      def process_break(exp)
        _ = exp
      end

      def process_dregx(exp)
        _, regex = exp
      end

      def process_super(exp)
        _, args = exp
        process(args)
      end

      def process_ensure(exp)
        _, rescue_clause, *ensure_clause = exp
        process(rescue_clause)
        ensure_clause.map! {|sub_tree| process(sub_tree)}
      end

      def process_op_asgn2(exp)
        _, left_assign, variable, method, args = exp
        process(left_assign)
        process(args)
      end

      def process_splat(exp)
        _, left_assign = exp
        process(left_assign)
      end

      def process_dxstr(exp)
        # shelling out
        _ = exp
      end

      def process_dot3(exp)
        _ = exp
      end

      def ruby_parser
        RubyParser.new
      end
    end

  end
end
