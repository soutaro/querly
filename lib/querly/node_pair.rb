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

    def each_subpair(&block)
      if block_given?
        return unless node

        yield self

        children.each do |child|
          child.each_subpair(&block)
        end
      else
        enum_for :each_subpair
      end
    end
  end
end
