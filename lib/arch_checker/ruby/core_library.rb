module ArchChecker
  module Ruby
    CORE_LIB_NAME = 'ruby_core_lib'
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
  end
end
