require 'set'
require 'pry'

module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class ParserForTypeinference < SexpInterpreter
          attr_reader :dependencies, :method_definitions

          def initialize
            super()
            @current_scope = LocalScope.new
            @current_dependency_class = []
            @current_dependency_class_name = nil
            @current_class = nil
            @module_names = []
            @complete_class_name = []
            @classes = []
            @current_class = []
            @method_definitions = []
            @dependencies = []
          end

          def parse(content)
            ast = ruby_parser.parse(content)
            process(ast)
            [@dependencies, @method_definitions]
          end

          def process_block(exp)
            _, *args = exp
            args.map! { |subtree| process(subtree) }
          end

          def process_lasgn(exp)
            _, variable_name, *args = exp
            args.map! { |subtree| process(subtree) }
            if @current_dependency_class_name
              @current_scope.add_variable(variable_name, @current_dependency_class_name)
            end
            @current_dependency_class_name = nil
          end

          def process_call(exp)
            _, receiver, method_name, *args = exp
            process(receiver)
            args.map! { |subtree| process(subtree) }
          end

          def process_const(exp)
            _, const_name = exp
            if !@current_dependency_class.empty?
              @current_dependency_class_name = build_full_name(const_name)
            else
              @current_dependency_class_name = const_name.to_s
            end
            add_dependencies(nil, nil, @current_dependency_class_name)
          end

          def process_colon2(exp)
            _, first_part, last_part = exp
            @current_dependency_class.unshift(last_part)
            process(first_part)
          end

          def process_colon3(exp)
            _, constant_name = exp
            const_name = build_full_name("::#{constant_name}")
            add_dependencies(nil, nil, const_name)
          end

          def build_full_name(const_name)
            @current_dependency_class.unshift(const_name)
            full_class_path = @current_dependency_class.join('::')
            @current_dependency_class = []
            full_class_path
          end

          def process_module(exp)
            _, module_name, *args = exp
            if module_name.class == Symbol
              @module_names.push(module_name.to_s)
            end
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_class exp
            _, class_name, *args = exp
            if class_name.class == Symbol
              if !@module_names.empty?
                @classes << "#{@module_names.join("::")}::#{class_name}"
              else
                @classes << class_name.to_s
              end
              @current_class << @classes.last
            else
              # cai aqui quando a definicao é algo do tipo: class Teste::De end
              get_complete_class_name class_name
              @classes << @complete_class_name.join("::")
              @complete_class_name = []
              @current_class << @classes.last
            end
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp}
            @current_class.pop
          end

          def get_complete_class_name exp
            if exp[0] == :const
              _, const_name = exp
              @complete_class_name.unshift const_name
              return
            else
              _, first_part, last_constant_part = exp
              if ( _ == :colon3 )
                process(exp)
              else
                @complete_class_name.unshift(last_constant_part)
                get_complete_class_name first_part
              end
            end
          end

          def process_defn(exp)
            _, method_name, method_arguments, *method_body = exp
            @current_scope.add_new_scope
            args = ProcessMethodArguments.new(method_arguments).parse
            populate_scope_with_formal_parameters(args)
            method_calls = ProcessMethodBody.new(method_body, @current_scope).parse
            add_method_definition(method_name, args, method_calls)
            add_dependencies(args, method_calls)
            @current_scope.remove_scope
          end

          def process_defs(exp)
            #transformando em um defn
            without_node_type = exp[2..-1].to_a
            without_node_type.unshift(:defn)
            new_sexp = Sexp.from_array(without_node_type)
            process_defn(new_sexp)
          end

          def add_method_definition(method_name, args, method_calls)
            @method_definitions << MethodDefinition.new(
                                    @classes.last,
                                    method_name,
                                    args,
                                    method_calls
                                  )
          end

          def add_dependencies(args = nil, method_calls = nil, class_name = nil)
            return if @current_class.last.nil?
            class_dependency = ClassDependency.new(@classes.last)
            if class_name
              class_dependency.add_dependency(class_name)
            end
            if args
              args.each do |key, value|
                if value.length > 0 #it is a set object
                  class_dependency.add_dependency(value.first)
                end
              end
            end
            if method_calls
              method_calls.each do |method_call|
                class_dependency.add_dependency(method_call.class_name)
              end
            end
            @dependencies << class_dependency
          end

          def populate_scope_with_formal_parameters(args)
            if !args.empty?
              args.each do |key, value|
                #value it is a set object
                @current_scope.add_formal_parameter(key, value.first)
              end
            end
          end

          def process_lit(exp)
          end

          def process_cdecl(exp)
          end

          def process_if(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp }
          end

          def process_array(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_gvar(exp)
            #global variables
          end

          def process_and(exp)
            _, left_side, right_side = exp
            process(left_side)
            process(right_side)
          end

          def process_or(exp)
            _, left_side, right_side = exp
            process(left_side)
            process(right_side)
          end

          def process_case(exp)
            _, condition, when_part, ensure_part = exp
            process(condition)
            process(when_part)
            process(ensure_part)
          end

          def process_when(exp)
            _, condition, body = exp
            process(condition)
            process(body)
          end

          def process_rescue(exp)
            _, body, rescbody = exp
            process(body)
            process(rescbody)
          end

          def process_dregx(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_dregx_once(exp)
            _, start, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp}
          end

          def process_evstr(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_dxstr(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_resbody(exp)
            _, body, resbody = exp
            process(body)
            process(resbody)
          end

          def process_ensure(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_block_pass(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_op_asgn2(exp)
            _, receiver, method, met, last = exp
            process(receiver)
            process(last)
          end

          def process_return(exp)
          end

          def process_next(exp)
          end

          def process_alias(exp)
          end

          def process_ivar(exp)
            _, var_name, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_svalue(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_not(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_dot2(exp)
            _, left, right = exp
            process(left)
            process(right)
          end

          def process_to_ary(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_masgn(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_match2(exp)
            _, rec, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_match3(exp)
            _, first, second = exp
            process(first)
            process(second)
          end

          def process_while(exp)
            _, condition, body = exp
            process(condition)
            process(body)
          end

          def process_until(exp)
            _, condition, body = exp
            process(condition)
            process(body)
          end

          def process_for(exp)
            _, x, y, body = exp
            process(x)
            process(y)
            process(body)
          end

          def process_valias(exp)

          end

          def process_xstr(exp)
          end

          def process_lvar(exp)
            #chamado para pegar o valor
          end

          def process_str(exp)
          end

          def process_begin(exp)
          end

          def process_retry(exp)
          end

          def process_cvdecl(exp)
            _, instance_classvar_name, *value = exp
            value.map! {|sub_tree| process(sub_tree)}
          end

          def process_defined(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_postexe(exp)
          end

          def process_iasgn(exp)
            _, instance_varialbe_name, *value = exp
            value.map! { |subtree| process(subtree) }
          end

          def process_dsym(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_undef(exp)
          end

          def process_super(exp)
          end

          def process_attrasgn(exp)
            _, receiver, method, arg, value = exp
            process(receiver)
            process(value)
          end

          def process_splat(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_iter(exp)
            _, first_part, second_part, *body = exp
            process(first_part)
            body.map! {|sub_tree| process(sub_tree)}
          end

          def process_sclass(exp)
            _, singleton_class, *body = exp
            body.map! {|sub_tree| process(sub_tree)}
          end

          def process_hash(exp)
            _, key, value = exp
            process(key)
            process(value)
          end

          def process_op_asgn1(exp)
            _, receiver, arg, method_name, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_op_asgn_or(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_gasgn(exp)
            _, global_var_name, *value = exp
            value.map! {|sub_tree| process(sub_tree)}
          end

          def process_cvar(exp)
            # class variable
          end

          def process_break(exp)
          end

          def process_nth_ref(exp)
          end

          def process_dstr(exp)
            # string dinamica, pode ser interessante se
            # quisermos pegar alguma coisa dentro delas

          end

          def process_true(exp)
          end

          def process_false(exp)
          end

          def process_self(exp)
          end

          def process_nil(exp)
          end

          # def process_sclass(exp)
          #   binding.pry
          # end

          def ruby_parser
            RubyParser.new
          end
        end

      end
    end
  end
end
