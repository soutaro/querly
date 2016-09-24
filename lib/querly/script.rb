module Querly
  class Script
    attr_reader :path
    attr_reader :node

    def initialize(path:, node:)
      @path = path
      @node = node
    end

    def root_pair
      NodePair.new(node: node)
    end
  end
end
