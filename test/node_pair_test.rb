require_relative "test_helper"

class NodePairTest < Minitest::Test
  include TestHelper

  def test_each_subpair
    node = ruby("foo(bar(baz))")
    pair = Querly::NodePair.new(node: node)

    nodes = pair.each_subpair.map(&:node)

    assert_equal 3, nodes.count
    assert nodes.include?(ruby("baz"))
    assert nodes.include?(ruby("bar(baz)"))
    assert nodes.include?(ruby("foo(bar(baz))"))
  end
end
