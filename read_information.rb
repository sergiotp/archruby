require 'csv'
require 'set'
require 'pry'

CORE_LIBRARY_CLASSES = [
  'Array', 'Bignum', 'BasicObject', 'Object', 'Module', 'Class', 'Complex', 'Complex::compatible',
  'NilClass', 'Numeric', 'String', 'Float', 'Fiber', 'FiberError', 'Continuation', 'Dir', 'File',
  'Encoding', 'Enumerator', 'StopIteration', 'Enumerator::Lazy', 'Enumerator::Generator',
  'Enumerator::Yielder', 'Exception', 'SystemExit', 'fatal', 'SignalException', 'Interrupt',
  'StandardError', 'TypeError', 'ArgumentError', 'IndexError', 'KeyError', 'RangeError',
  'ScriptError', 'SyntaxError', 'LoadError', 'NotImplementedError', 'NameError', 'NoMethodError',
  'RuntimeError', 'SecurityError', 'NoMemoryError', 'EncodingError', 'SystemCallError',
  'Encoding::CompatibilityError', 'File::Stat', 'IO', 'ObjectSpace::WeakMap', 'Hash', 'ENV',
  'IOError', 'EOFError', 'ARGF', 'RubyVM', 'RubyVM::InstructionSequence', 'Math::DomainError',
  'ZeroDivisionError', 'FloatDomainError', 'Integer', 'Fixnum', 'Data', 'TrueClass', 'FalseClass',
  'Thread', 'Proc', 'LocalJumpError', 'SystemStackError', 'Method', 'UnboundMethod', 'Binding',
  'Process::Status', 'Random', 'Range', 'Rational', 'Rational::compatible', 'RegexpError',
  'Regexp', 'MatchData', 'Symbol', 'Struct', 'ThreadGroup', 'Mutex', 'ThreadError', 'Time',
  'Encoding::UndefinedConversionError', 'Encoding::InvalidByteSequenceError',
  'Encoding::ConverterNotFoundError', 'Encoding::Converter', 'RubyVM::Env', 'Thread::Backtrace',
  'Thread::Backtrace::Location', 'TracePoint', 'Comparable', 'Kernel', 'File::Constants',
  'Enumerable', 'Errno', 'FileTest', 'GC', 'ObjectSpace', 'GC::Profiler', 'IO::WaitReadable',
  'IO::WaitWritable', 'Marshal', 'Math', 'Process', 'Process::UID', 'Process::GID', 'Process::Sys',
  'Signal'
]

STD_LIBRARY_CLASSES = [
  'MAbbrev', 'Base64', 'Benchmark', 'BigDecimal', 'BigMath', 'Jacobian',
  'LUSolve', 'Newton', 'CGI', 'Coverage','CSV', 'Curses', 'FileViewer', 'Date',
  'DateTime', 'DBM', 'DBMError', 'SimpleDelegator', 'Delegator', 'Digest',
  'DL', 'ACL', 'DRb', 'E2MM', 'English', 'ERB', 'Etc', 'RbConfig', 'FileUtils',
  'Fcntl', 'Fiddle', 'FileUtils', 'Find', 'Forwardable', 'SingleForwardable',
  'GDBM', 'GDBMError', 'GDBMFatalError', 'GetoptLong', 'GServer', 'IPAddr', 'IRB', 'JSON',
  'Logger', 'Matrix', 'Vector', 'MiniTest', 'MakeMakefile', 'Monitor', 'MonitorMixin', 'Mutex_m',
  'Net', 'NKF', 'Kconv', 'Observable', 'OpenURI', 'URI', 'Open3', 'OpenSSL', 'OptionParser', 'OpenStruct',
  'Pathname', 'PP', 'PrettyPrint', 'Prime', 'PStore', 'Psych', 'PTY', 'Racc', 'Rake', 'RDoc',
  'Readline', 'Resolv', 'IPSocket', 'TCPSocket', 'UDPSocket', 'SOCKSSocket', 'REXML', 'Rinda',
  'Ripper', 'RSS', 'Gem', 'Scanf', 'SDBM', 'SDBMError', 'SecureRandom', 'Set', 'SortedSet', 'Shell',
  'Shellwords', 'Singleton', 'UNIXServer', 'UNIXSocket', 'TCPServer', 'BasicSocket', 'Socket',
  'StringIO', 'StringScanner', 'Sync', 'Syslog', 'Tempfile', 'ConditionVariable', 'Queue',
  'SizedQueue', 'ThWait', 'Timeout', 'TSort', 'WeakRef', 'WEBrick', 'XMLRPC', 'YAML',
  'Zlib', 'Iconv'
]

dependencies_arch = {}
dependencies_dynamic = {}

def populate_dependencies(row, dependency_hash)
  if row[0].include?("Arch")
    class_name = row[0].strip
    method_name = row[1].strip
    dependency_hash[class_name] ||= {}
    #dependency_hash[class_name][method_name] ||= {}
    dependency_hash[class_name][method_name] ||= Set.new

    variables_and_types = row[2..row.length].join(",")
    variables, var_types = variables_and_types.split("|")
    variables = variables.split(",")
    if var_types
      var_types = var_types.split(",")
    else
      var_types = []
    end

    var_types.each do |v_t|
      dependency_hash[class_name][method_name].add(v_t.strip)
    end
    # variables.each_with_index do |var, index|
    #   var = var.strip
    #   dependency_hash[class_name][method_name][var] ||= Set.new
    #   if var_types[index]
    #     dependency_hash[class_name][method_name][var].add(var_types[index].strip)
    #   end
    # end
  end

end


CSV.foreach("information_archruby.csv") do |row|
  populate_dependencies(row, dependencies_arch)
end

CSV.foreach("information.csv") do |row|
  populate_dependencies(row, dependencies_dynamic)
end

def total_deps(dependencies)
  countable_dependencies = Set.new
  var_deps_countable = {}
  total_dep = 0
  dependencies.each do |class_name, deps|
    deps.each do |method_name, method_deps|
      method_deps.each do |var_name, var_types|
        var_types.each do |type|
          if !CORE_LIBRARY_CLASSES.include?(type.strip) && !STD_LIBRARY_CLASSES.include?(type.strip)
            name = "#{method_name.strip}##{var_name.strip}"
            countable_dependencies.add(type)
            var_deps_countable[name] ||= Set.new
            var_deps_countable[name].add(type)
            #total_dep += 1
          end
        end
      end
    end
  end
  countable_dependencies.size
  var_deps_countable
  #binding.pry
  #total_dep
end

binding.pry
