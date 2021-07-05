module Querly
  class Script
    attr_reader :path
    attr_reader :node

    def self.load(path:, source:)
      parser = Parser::Ruby30.new(Builder.new).tap do |parser|
        parser.diagnostics.all_errors_are_fatal = true
        parser.diagnostics.ignore_warnings = true
      end
      buffer = Parser::Source::Buffer.new(path.to_s, 1)
      buffer.source = source
      self.new(path: path, node: parser.parse(buffer))
    end

    def initialize(path:, node:)
      @path = path
      @node = node
    end

    def root_pair
      NodePair.new(node: node)
    end

    class Builder < Parser::Builders::Default
      def string_value(token)
        value(token)
      end

      def emit_lambda
        true
      end
    end
  end
end
