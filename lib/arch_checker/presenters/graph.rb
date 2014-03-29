require 'graphviz'

module ArchChecker
  module Presenters

    class Graph

      def render architecture
        modules = architecture.modules

        g = GraphViz.new(:G, :overlap => false, :splines => true, :sep => "+40,40", :nodesep => 1)

        g.edge[:color] = "black"
        g.edge[:style] = "filled"
        g.edge[:label] = ""

        internal = g.subgraph("internal", "label" => "Internal", "color" => "black", "rank" => "same")

        external = g.subgraph("external", "label" => "External", "color" => "black", "rank" => "same")

        nodes = {}

        internal_nodes = []
        external_nodes = []
        modules.each do |module_definiton|
          if module_definiton.is_external?
            nodes[module_definiton.name] = external.add_nodes(module_definiton.name, "shape" => "parallelogram", "color" => "gray60", "style" => "filled")
            external_nodes << nodes[module_definiton.name]
          else
            if module_definiton.is_empty?
              nodes[module_definiton.name] = internal.add_nodes("#{module_definiton.name}\n [empty]", "color" => "gray74", "shape" => "rectangle")
            else
              nodes[module_definiton.name] = internal.add_nodes(module_definiton.name, "color" => "gray92", "style" => "filled", "shape" => "rectangle")
            end
            internal_nodes << nodes[module_definiton.name]
          end
        end

        edges = {}
        edges_objs = []

        modules.each do |module_definiton|
          module_name = module_definiton.name
          node_origin = nodes[module_name]
          edges[module_name] ||= {}
          edges[module_name][:edges] ||= []

          module_definiton.dependencies.each do |class_name|
            module_dest = architecture.module_name class_name
            how_many_access = architecture.how_many_access_to module_name, module_dest
            if !edges[module_name][:edges].include?(module_dest) && module_dest != module_name
              edges[module_name][:edges] << module_dest
              node_dest = nodes[module_dest]
              edges_objs << internal.add_edges(node_origin, node_dest, :headlabel => how_many_access, :minlen => 2)
            end
          end
        end

        constraints_breaks = architecture.constraints_breaks
        constraints_breaks.each_with_index do |constraint_break, index|
          module_origin = constraint_break.module_origin
          module_target = constraint_break.module_target
          contraint_type = constraint_break.type
          node_origin = nodes[module_origin]
          node_dest = nodes[module_target]
          node_found = false
          edges_objs.each do |edge|
            if edge.node_one == module_origin && edge.node_two == module_target
              if contraint_type == ArchChecker::Architecture::ConstraintBreak::ABSENSE
                edge.set do |e|
                  e.headlabel = "X (##{architecture.how_many_break(module_origin, module_target,  ArchChecker::Architecture::ConstraintBreak::ABSENSE)})"
                  e.color = "red"
                  e.style = "bold"
                  e.minlen = 2
                end
              else
                edge.set do |e|
                  e.headlabel = "! (##{architecture.how_many_break(module_origin, module_target, ArchChecker::Architecture::ConstraintBreak::DIVERGENCE)})"
                  e.color = "orange"
                  e.style = "bold"
                  e.minlen = 2
                end
              end
              node_found = true
              break
            end
          end

          if !node_found
            if contraint_type == ArchChecker::Architecture::ConstraintBreak::ABSENSE
              break_count = architecture.how_many_break(module_origin, module_target, ArchChecker::Architecture::ConstraintBreak::ABSENSE)
              edges_objs << g.add_edges(node_origin, node_dest, :color => 'red', :headlabel => "X (##{break_count})", 'style' => 'bold', :minlen => 2)
            else
              break_count = architecture.how_many_break(module_origin, module_target, ArchChecker::Architecture::ConstraintBreak::DIVERGENCE)
              edges_objs << g.add_edges(node_origin, node_dest, :color => 'red', :headlabel => "! (##{break_count})", 'style' => 'bold', :minlen => 2)
            end
          end
        end

        modules.each do |module_definiton|
          module_origin = module_definiton.is_empty? ? "#{module_definiton.name}\n [empty]" : module_definiton.name
          node_origin = nodes[module_origin]
          puts module_definiton.name.inspect
          puts module_definiton.classes.inspect
          module_definiton.allowed_modules.each do |allowed_module_name|
            module_target = allowed_module_name
            node_dest = nodes[allowed_module_name]
            edge_found = false
            edges_objs.each do |edge|
              if edge.node_one == module_origin && edge.node_two == module_target
                edge_found = true
                break
              end
            end
            if !edge_found
              internal.add_edges(node_origin, node_dest, :color => 'gray74', :label => "[none]", :minlen => 2)
            end
          end
        end

        g.output( :none => "architecture2.dot" )
      end

    end
  end
end
