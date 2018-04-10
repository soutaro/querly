# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'querly/version'

Gem::Specification.new do |spec|
  spec.name          = "querly"
  spec.version       = Querly::VERSION
  spec.authors       = ["Soutaro Matsumoto"]
  spec.email         = ["matsumoto@soutaro.com"]

  spec.summary       = %q{Pattern Based Checking Tool for Ruby}
  spec.description   = %q{Querly is a query language and tool to find out method calls from Ruby programs. Define rules to check your program with patterns to find out *bad* pieces. Querly finds out matching pieces from your program.}
  spec.homepage      = "https://github.com/soutaro/querly"

  spec.files         = `git ls-files -z`
    .split("\x0")
    .reject { |f| f.match(%r{^(test|spec|features)/}) }
    .push('lib/querly/pattern/parser.rb')
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "racc", "= 1.4.14"
  spec.add_development_dependency "unification_assertion", "0.0.1"

  spec.add_dependency 'thor', ">= 0.19.0", "< 0.21.0"
  spec.add_dependency "parser", "~> 2.5.0"
  spec.add_dependency "rainbow", "~> 3.0"
  spec.add_dependency "activesupport", "~> 5.0"
end
