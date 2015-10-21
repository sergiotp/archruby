require 'imgkit'
require_relative 'cell_dsm'

module Archruby
  module Presenters

    class DSM

      def render(architecture)
        matrix = create_DSM(architecture)
        html = create_HTML(getModules(architecture), matrix)
        save_img(html)
      end
      
      def save_img(html)
         path_css = File.absolute_path("../lib/archruby/presenters/css.css")
         path_img = File.absolute_path("architecture_dsm.png")   
         kit = IMGKit.new(html,:quality => 100)
         kit.stylesheets << path_css
         kit.to_file(path_img)
      end

      def create_DSM(architecture)
        modules = getModules(architecture)
        index = create_hash_index(modules)
        matrix ||= Array.new(modules.size()) { Array.new(modules.size()) }

        #adiciona na matriz todas as dependências permitidas
        modules.each do |module_definiton|
          module_name = module_definiton.name
          module_definiton.dependencies.each do |class_name|
            module_dest = architecture.module_name class_name
            next if module_dest == Archruby::Ruby::STD_LIB_NAME || module_dest == Archruby::Ruby::CORE_LIB_NAME
            next if module_dest == 'unknown'
            how_many_access = architecture.how_many_access_to module_name, module_dest
            if module_dest != module_name
              matrix[index[module_dest]][index[module_name]] = CellDSM.new(how_many_access, "allowed")
            end
          end
        end

        #adiciona na matriz todas as violações
        constraints_breaks = architecture.constraints_breaks
        constraints_breaks.each do |constraint_break|
          module_origin = constraint_break.module_origin
          module_target = constraint_break.module_target
          contraint_type = constraint_break.type
          how_many_access = -1
          if (contraint_type == Archruby::Architecture::ConstraintBreak::ABSENSE)
            how_many_access = architecture.how_many_break(module_origin, module_target, Archruby::Architecture::ConstraintBreak::ABSENSE)
          else
            how_many_access = architecture.how_many_break(module_origin, module_target, Archruby::Architecture::ConstraintBreak::DIVERGENCE)
          end
          matrix[index[module_target]][index[module_origin]] = CellDSM.new(how_many_access,contraint_type)
        end
        return matrix
      end

      def create_HTML(modules,matrix)
        text = "\n<center><table>\n"
        text = "#{text}    <tr>\n"
        text = "#{text}      <th>Modules</th>\n"
        for i in 0..(modules.size-1)
          if(modules[i].is_external?)
            text = "#{text}      <td  width='8%' id='external'><center>#{i+1}</center></td>\n"
          else
            text = "#{text}      <td  width='8%' id='internal'><center>#{i+1}</center></td>\n"
          end          
        end
        text = "#{text}    </tr>\n"
        for line in 0..(matrix.size - 1) 
            text = "#{text}  <tr>\n"
            if(modules[line].is_external?)
              text = "#{text}    <td id='external'><div id='module'>#{modules[line].name}</div><div id='number'>#{line+1}</div></td>\n"
            else
              text = "#{text}    <td id='internal'><div id='module'>#{modules[line].name}</div><div id='number''>#{line+1}</div></td>\n"
            end
          for column in 0..(matrix.size - 1)
            if(line == column)
              text = text + "    <td id='diagonal'></td>\n"
            elsif (matrix[line][column].nil?)
              text = text + "    <td id='default'></td>\n"
            elsif (matrix[line][column].type.eql? "absence")
              text = text + "    <td id='absence'><center>#{matrix[line][column].how_many_access}</center></td>\n"
            elsif (matrix[line][column].type.eql? "divergence")
              text = text + "    <td id='divergence'><center>#{matrix[line][column].how_many_access}</center></td>\n"
            else
              text = text + "    <td id='default'><center>#{matrix[line][column].how_many_access}</center></td>\n"
            end
          end
          text = "#{text}  </tr>\n"          
        end
        text = "#{text}</table> </center>"
        return text
      end

      def getModules(architecture)
        modules ||= []
        architecture.modules.each do |module_definiton|
          next if module_definiton.name == 'unknown'
          next if module_definiton.name == Archruby::Ruby::STD_LIB_NAME || module_definiton.name == Archruby::Ruby::CORE_LIB_NAME
          modules << module_definiton
        end
        return modules
      end

      def create_hash_index(modules)
        index = Hash.new()
        for i in 0..(modules.size() - 1)
          index[modules[i].name] = i
        end
        return index
      end

    end
  end
end
