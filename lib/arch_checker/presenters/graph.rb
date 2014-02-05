require 'graphviz'

module ArchChecker
  module Presenters

    class Graph
      def render constraint_breaks
        g = GraphViz.new( :G, :type => :digraph )
        
        constraint_breaks.each do |constraint_break|
          constraint_break.each do |violations|
            module_1 = violations.keys.first
            module_2 = violations[module_1].split(" ").last
            node_1 = g.add_nodes(module_1.to_s)
            node_2 = g.add_nodes(module_2)
            g.add_edges( node_1, node_2 )
          end
        end

        g.output( :png => "architecture_break.png" )
      end
      
    end
  end
end