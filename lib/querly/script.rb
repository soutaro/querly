module Querly
  class Script
    attr_reader :path
    attr_reader :node

    def initialize(path:, node:)
      @path = path
      @node = node
    end

    def self.from_path(path)
      self.new(path: path, node: Parser::CurrentRuby.parse(path.read, path.to_s))
    end

    def self.from_source(source, path = Pathname("-"))
      self.new(path: path, node: Parser::CurrentRuby.parse(source, path.to_s))
    end

    def root_pair
      NodePair.new(node: node)
    end
  end
end
