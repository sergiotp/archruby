module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class ProcessMethodArguments < SexpInterpreter
          def initialize(ast)
            super()
            @ast = ast
            @params = {}
            @current_dependency_class = []
            @current_dependency_class_name = nil
          end

          def parse
            #binding.pry
            process(@ast)
            @params
          end

          def process_args(exp)
            _, *args = exp
            if !args.empty?
              args.each do |arg|
                if arg.class == Symbol
                  @params[arg] ||= Set.new
                else
                  process(arg) if arg.class == Sexp
                end
              end
              # if args.first.class == Symbol
              #   @params[args.first] ||= Set.new
              # else
              #   args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp}
              # end
            end
          end

          def process_lasgn(exp)
            _, variable_name, *args = exp
            @params[variable_name] ||= Set.new
            args.map! {|sub_tree| process(sub_tree)}
            @params[variable_name].add(@current_dependency_class_name)
            @current_dependency_class_name = nil
          end

          def process_lit(exp)
            _, value = exp
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
          end

          def process_colon2(exp)
            _, first_part, last_part = exp
            @current_dependency_class.unshift(last_part)
            process(first_part)
          end

          def process_colon3(exp)
            _, constant_name = exp
            @current_dependency_class_name = build_full_name("::#{constant_name}")
          end

          def build_full_name(const_name)
            @current_dependency_class.unshift(const_name)
            full_class_path = @current_dependency_class.join('::')
            @current_dependency_class = []
            full_class_path
          end

          def process_hash(exp)
            _, key, value = exp
            @current_dependency_class_name = "Hash"
            process(key)
            process(value)
          end

          def process_if(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp }
          end

          def process_kwarg(exp)
            _, *args = exp
            args.map! { |subtree| process(subtree) if subtree.class == Sexp}
          end

          def process_array(exp)
            _, *args = exp
            @current_dependency_class_name = "Array"
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_ivar(exp)
            _, var_name, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_iter(exp)
            _, first_part, second_part, *body = exp
            process(first_part)
            body.map! {|sub_tree| process(sub_tree)}
          end

          def process_cvasgn(exp)
            _, class_var_name, *value = exp
            value.map! {|sub_tree| process(sub_tree)}
          end

          def process_masgn(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp}
          end

          def process_or(exp)
            _, left_side, right_side = exp
            process(left_side)
            process(right_side)
          end

          def process_lvar(exp)
          end

          def process_cvar(exp)
            # class variable
          end

          def process_true(exp)
          end

          def process_nil(exp)
            @current_dependency_class_name = "NilClass"
          end

          def process_str(exp)
          end

          def process_false(exp)
          end

          def process_self(exp)
          end

          def process_gvar(exp)
            #global variables
          end

        end

      end
    end
  end
end
