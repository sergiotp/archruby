require 'graphviz'

module ArchChecker
  module Presenters

    class Graph
      
      def render architecture
        modules = architecture.modules

        g = GraphViz.new( :G, :type => :digraph )
        nodes = {}
        edges = []
        modules.each do |module_definiton|
          if module_definiton.is_external?
            nodes[module_definiton.name] = g.add_nodes(module_definiton.name, :shape => "box")
          else
            nodes[module_definiton.name] = g.add_nodes(module_definiton.name)
          end
        end
        
        modules.each do |module_definiton|
          module_name = module_definiton.name
          node_origin = nodes[module_name]

          module_definiton.required_modules.each do |required_module_name|
            node_dest = nodes[required_module_name]
            edges << g.add_edges(node_origin, node_dest)
          end
          
          module_definiton.allowed_modules.each do |allowed_module_name|
            node_dest = nodes[allowed_module_name]
            edges << g.add_edges(node_origin, node_dest)
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
          edges.each do |edge|
            if edge.node_one == module_origin && edge.node_two == module_target
              if contraint_type == ArchChecker::Architecture::ConstraintBreak::ABSENSE
                edge.set do |e|
                  e.label = "X [#{architecture.how_many_break(module_origin, ArchChecker::Architecture::ConstraintBreak::ABSENSE)}]"
                  e.color = "red"
                  e.style = "bold"
                  e.weight = 1
                end
              else
                edge.set do |e|
                  e.label = "! [#{architecture.how_many_break(module_origin, ArchChecker::Architecture::ConstraintBreak::DIVERGENCE)}]"
                  e.color = "red"
                  e.weight = 3
                end                
              end
              node_found = true
              break
            end
          end

          if !node_found
            if contraint_type == ArchChecker::Architecture::ConstraintBreak::ABSENSE
              break_count = architecture.how_many_break(module_origin, ArchChecker::Architecture::ConstraintBreak::ABSENSE)
              edges << g.add_edges(node_origin, node_dest, :color => 'red', :label => "X [#{break_count}]", 'weight' => 1, 'style' => 'bold')
            else
              break_count = architecture.how_many_break(module_origin, ArchChecker::Architecture::ConstraintBreak::DIVERGENCE)
              edges << g.add_edges(node_origin, node_dest, :color => 'red', :label => "! [#{break_count}]", 'weight' => 3)
            end
          end
        end
        
        g.output( :png => "architecture.png" )
      end
      
    end
  end
end