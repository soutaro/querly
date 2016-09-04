module Querly
  class NodePair
    attr_reader :node
    attr_reader :parent

    def initialize(node:, parent: nil)
      @node = node
      @parent = parent
    end

    def children
      node.children.flat_map do |child|
        if child.is_a?(Parser::AST::Node)
          self.class.new(node: child, parent: self)
        else
          []
        end
      end
    end
  end
end
