# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archruby/version'

Gem::Specification.new do |spec|
  spec.name          = "archruby"
  spec.version       = Archruby::VERSION
  spec.authors       = ["Sergio Henrique"]
  spec.email         = ["sergiohenriquetp@gmail.com"]
  spec.description   = %q{Compliance and Architectural Visualization in Ruby systems}
  spec.summary       = %q{Compliance and Architectural Visualization in Ruby systems}
  spec.homepage      = "http://aserg.labsoft.dcc.ufmg.br/archruby/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  #spec.add_development_dependency "code_metrics/line_statistics"
  spec.add_runtime_dependency "ruby_parser"
  spec.add_runtime_dependency "sexp_processor"
  spec.add_runtime_dependency "ruby-graphviz"
  spec.add_runtime_dependency "imgkit"
  spec.add_runtime_dependency "wkhtmltoimage-binary"

end
