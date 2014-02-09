module ArchChecker
  module Architecture
    class FileContent

      def initialize base_directory
        # base_directory "/Users/sergiomiranda/Labs/ruby_arch_checker/arch_checker/spec/dummy_app/app"
        @base_directory = base_directory
      end
      
      def all_content_from_directory directory
        return if directory.nil? || directory.eql?("")
        content = {}
        file_paths = Dir.glob("#{@base_directory}/#{directory}")
        file_paths.each do | file_path |
          file = File.open(file_path, 'r')
          file_name = File.basename(file_path, '.rb')
          content[file_name] = file.read
        end
        content
      end
      
    end
  end
end