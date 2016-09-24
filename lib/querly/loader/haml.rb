require "haml"
require "parser"

module Querly
  module Loader
    module Haml
      def self.load(path, source)
        options = ::Haml::Options.new

        parser = ::Haml::Parser.new(source, options)
        parser.parse

        compiler = ::Haml::Compiler.new(options)

        compiler.compile(parser.root)

        compiler.precompiled
      end
    end
  end

  ScriptEnumerator.register_loader /\.haml$/, Loader::Haml
end
