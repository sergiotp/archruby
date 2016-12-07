if ENV['simplecov']
  require 'simplecov'
  SimpleCov.start do
    add_filter do |src|
      src.filename =~ /presenters/ || src.filename =~ /process_method_params/ ||
      src.filename =~ /parser_for_typeinference/ ||  src.filename =~ /process_method_body/ ||
      src.filename =~ /process_method_arguments/ || src.filename =~ /parser\.rb/
    end
  end
end

if ENV['tracepoint']
  # require 'pry'
  # binding.pry
  #trace = TracePoint.trace(:call, :c_call) do |tp|
  trace = TracePoint.trace(:line) do |tp|
    #p [tp.lineno, tp.defined_class, tp.method_id, tp.event]
    tp.disable

#    binding.pry
    if tp.path.include?("arch") && !tp.path.include?("helper") && tp.defined_class && !tp.defined_class.to_s.include?("<Class:")
      # puts tp.inspect
      # require 'pry'
      # binding.pry
      method_name = tp.method_id
      class_name = tp.defined_class
      # if class_name && class_name.to_s.include?("Archruby::Architecture::Parser") && method_name && method_name.to_s.include?("parse")
      #   binding.pry
      # end

      if !class_name.eql?(nil)
        file_path = file_path = File.expand_path('../../', __FILE__)
        file = File.open("#{file_path}/information.csv", 'a')
        current_binding = tp.binding
        #binding.pry
        local_vars = current_binding.local_variables
        local_vars_types = []
        local_vars.each do |loc_var|
          begin
            var = current_binding.local_variable_get(loc_var)
            local_vars_types << var.class
          rescue
          end
        end
        file.puts "#{class_name}, #{method_name}, #{local_vars.join(',')} | #{local_vars_types.join(',')}" rescue nil

        file.close
      end

    end

      tp.enable
    #rescue

    #end
  end

  trace.enable
end

require 'archruby'
