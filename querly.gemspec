# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'querly/version'

Gem::Specification.new do |spec|
  spec.name          = "querly"
  spec.version       = Querly::VERSION
  spec.authors       = ["Soutaro Matsumoto"]
  spec.email         = ["matsumoto@soutaro.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
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

  spec.add_dependency 'thor', "~> 0.19"
  spec.add_dependency "parser", "~> 2.3.1"
  spec.add_dependency "rainbow", "~> 2.1"
  spec.add_dependency "haml", "~> 4.0"
  spec.add_dependency "slim", "~> 3.0"
end
