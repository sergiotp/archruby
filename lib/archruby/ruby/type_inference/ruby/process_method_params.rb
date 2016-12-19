module Archruby
  module Ruby
    module TypeInference
      module Ruby

        class ProcessMethodParams < SexpInterpreter
          def initialize(ast, local_scope)
            super()
            @ast = ast
            @current_dependency_class = []
            @current_dependency_class_name = nil
            @local_scope = local_scope
            @params = []
            @new_params = []
            @pos = 0
          end

          def parse
            @ast.map! do |sub_tree|
              process(sub_tree)
              @pos += 1
            end
            [@params, @new_params]
          end

          def process_defn(exp)
            #estudar esse caso
          end

          def process_dregx_once(exp)
            _, start, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp}
          end

          def process_block(exp)
            _, *args = exp
            args.map! { |subtree| process(subtree) }
          end

          def process_kwsplat(exp)
            _, *args = exp
            args.map! { |subtree| process(subtree) }
          end

          def process_dot3(exp)
            _, left, right = exp
            process(left)
            process(right)
          end

          def process_lasgn(exp)
          end

          def process_lvar(exp)
            _, lvar_name = exp
            type = @local_scope.var_type(lvar_name)
            if type
              add_to_params(type)
            else
              add_to_params(lvar_name)
            end
            #chamado para pegar o valor
          end

          def process_const(exp)
            _, const_name = exp
            if !@current_dependency_class.empty?
              @current_dependency_class_name = build_full_name(const_name)
              add_to_params(@current_dependency_class_name)
              @current_dependency_class_name = nil
            else
              add_to_params(const_name)
            end
          end

          def process_call(exp)
            _, receiver, method_name, *params = exp
            process(receiver)
          end

          def process_block_pass(exp)
            _, *args = exp
            args.map! { |subtree| process(subtree) }
          end

          def add_to_params(name)
            @params[@pos] = name
            @new_params[@pos] = Set.new.add(name)
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
            process(key)
            process(value)
          end

          def process_splat(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_iasgn(exp)
            _, instance_varialbe_name, *value = exp
            value.map! { |subtree| process(subtree) }
          end

          def process_if(exp)
            _, condition, true_body, else_body = exp
            process(condition)
            process(true_body)
            process(else_body)
          end

          def process_iter(exp)
            _, first_part, second_part, *body = exp
            process(first_part)
            body.map! {|sub_tree| process(sub_tree)}
          end

          def process_dstr(exp)
            _, init, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_evstr(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_xstr(exp)
          end

          def process_array(exp)
            _, *elements = exp
            elements.map! {|sub_tree| process(sub_tree)}
          end

          def process_match2(exp)
            _, rec, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_defined(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_dxstr(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_dregx(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree) if sub_tree.class == Sexp }
          end

          def process_dot2(exp)
            _, left, right = exp
            process(left)
            process(right)
          end

          def process_dsym(exp)
            _, str, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_or(exp)
            _, left_side, right_side = exp
            process(left_side)
            process(right_side)
          end

          def process_and(exp)
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

          def process_attrasgn(exp)
            _, receiver, method, arg, value = exp
            process(receiver)
            process(value)
          end

          def process_yield(exp)
            _, *args = exp
            args.map! {|sub_tree| process(sub_tree)}
          end

          def process_match3(exp)
            _, first, second = exp
            process(first)
            process(second)
          end

          def process_nth_ref(exp)
          end

          def process_gvar(exp)
          end

          def process_back_ref(exp)
          end

          def process_lit(exp)
            _, value = exp
          end

          def process_cvar(exp)
            # class variable
          end

          def process_super(exp)
          end

          def process_nil(exp)
          end

          def process_self(exp)
            type = @local_scope.var_type("self")
            if type
              add_to_params(type)
            end
          end

          def process_str(exp)
            add_to_params("String")
          end

          def process_false(exp)
          end

          def process_true(exp)
          end

          def process_ivar(exp)
          end

          def process_zsuper(exp)
          end


        end

      end
    end
  end
end
