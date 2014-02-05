module ArchChecker
  module Presenters
    class Text
      def render constraint_breaks
        file = File.new('violations.txt', 'w')
        constraint_breaks.each do |constraint_break|
          constraint_break.each do |violations|
            file.puts "#{violations.keys.first} #{violations[violations.keys.first]}"
          end
        end        
      end
    end
  end
end