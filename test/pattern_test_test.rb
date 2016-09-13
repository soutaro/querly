require_relative "test_helper"

class PatternTestTest < Minitest::Test
  include TestHelper

  def test_ivar_without_name
    nodes = query_pattern("@", "@x.foo")
    assert_equal 1, nodes.size
    assert_equal :ivar, nodes.first.type
    assert_equal :@x, nodes.first.children.first
  end

  def test_ivar_with_name
    nodes = query_pattern("@x", "@x + @y")
    assert_equal 1, nodes.size
    assert_equal :@x, nodes.first.children.first
  end
end
