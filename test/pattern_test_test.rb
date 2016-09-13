require_relative "test_helper"

class PatternTestTest < Minitest::Test
  include TestHelper

  def assert_node(node, type:)
    refute_nil node
    assert_equal type, node.type
    yield node.children if block_given?
  end

  def test_ivar_without_name
    nodes = query_pattern("@", "@x.foo")
    assert_equal 1, nodes.size
    assert_node nodes.first, type: :ivar do |name, *_|
      assert_equal :@x, name
    end
  end

  def test_ivar_with_name
    nodes = query_pattern("@x", "@x + @y")
    assert_equal 1, nodes.size
    assert_node nodes.first, type: :ivar do |name, *_|
      assert_equal :@x, name
    end
  end

  def test_constant
    nodes = query_pattern("C", "C.f")
    assert_equal 1, nodes.size

    assert_node nodes.first, type: :const do |parent, name|
      assert_nil parent
      assert_equal :C, name
    end
  end

  def test_constant_with_parent
    nodes = query_pattern("A::B", "A::B::C")
    assert_node nodes.first, type: :const do |parent, name|
      assert_equal :B, name
    end
  end

  def test_constant_with_parent2
    nodes = query_pattern("B::C", "A::B::C")
    assert_node nodes.first, type: :const do |parent, name|
      assert_equal :C, name
    end
  end
end
