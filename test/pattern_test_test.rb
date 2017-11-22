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

  def test_symbol
    nodes = query_pattern(":symbol:", ":foo")
    assert_node nodes.first, type: :sym do |name, *_|
      assert_equal :foo, name
    end
  end

  def test_symbol2
    nodes = query_pattern(":foo", ":foo.bar(:baz)")
    assert_equal 1, nodes.size
    assert_node nodes.first, type: :sym do |name, *_|
      assert_equal :foo, name
    end
  end

  def test_string
    nodes = E::Literal.new(type: :string, values: ["foo"])
    assert nodes.test_node(ruby('"foo"'))
    refute nodes.test_node(ruby('"bar"'))
  end

  def test_string2
    nodes = E::Literal.new(type: :string, values: ["foo", "bar"])
    assert nodes.test_node(ruby('"foo"'))
    assert nodes.test_node(ruby('"bar"'))
    refute nodes.test_node(ruby('"baz"'))
  end

  def test_string3
    nodes = E::Literal.new(type: :string, values: [/foo/])
    assert nodes.test_node(ruby('"foo bar"'))
    refute nodes.test_node(ruby('"baz"'))
  end

  def test_call_without_args
    nodes = query_pattern("foo", "foo(); foo(1)")
    assert_equal 2, nodes.size
    assert_equal ruby("foo()"), nodes[0]
    assert_equal ruby("foo(1)"), nodes[1]
  end

  def test_call_with_no_arg
    nodes = query_pattern("foo()", "foo(); foo(1)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo()"), nodes.first
  end

  def test_call_with_any_args
    nodes = query_pattern("foo(1, ...)", "foo(0); foo(1, 2); foo(x, y)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(1, 2)"), nodes.first
  end

  def test_call_with_any_expr_arg
    nodes = query_pattern("foo(_)", "foo(1, 2); foo(x)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(x)"), nodes.first
  end

  def test_call_with_not_expr_arg
    nodes = query_pattern("foo(!1)", "foo(1); foo(2)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(2)"), nodes.first
  end

  def test_call_with_kw_args1
    nodes = query_pattern("foo(bar: _)", "foo(bar: true)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(bar: true)"), nodes.first
  end

  def test_call_with_kw_args2
    nodes = query_pattern("foo(bar: _)", "foo(bar: true, baz: 1)")
    assert_empty nodes
  end

  def test_call_with_kw_args3
    nodes = query_pattern("foo(bar: _)", "foo({ bar: true }, baz: 1)")
    assert_empty nodes
  end

  def test_call_with_kw_args4
    nodes = query_pattern("foo(_, baz: 1)", "foo({ bar: true }, baz: 1)")
    assert nodes.one?
    assert_equal ruby("foo({ bar: true }, baz: 1)"), nodes.first
  end

  def test_call_with_kw_args5
    nodes = query_pattern("foo(..., baz: 1)", "foo(0, baz: 1)")
    assert nodes.one?
    assert_equal ruby("foo(0, baz: 1)"), nodes.first
  end

  def test_call_with_kw_args6
    nodes = query_pattern("foo(..., baz: 1)", "foo(1, baz: 2)")
    assert_empty nodes
  end

  def test_call_with_kw_args_rest1
    nodes = query_pattern("foo(bar: _, ...)", "foo(bar: true, baz: false)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(bar: true, baz: false)"), nodes.first
  end

  def test_call_with_kw_args_rest2
    nodes = query_pattern("foo(bar: _, ...)", "foo(baz: false)")
    assert_empty nodes
  end

  def test_call_with_negated_kw1
    nodes = query_pattern("foo(!bar: 1)", "foo(bar: 3)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(bar: 3)"), nodes.first
  end

  def test_call_with_negated_kw2
    nodes = query_pattern("foo(!bar: 1, ...)", "foo(baz: true)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(baz: true)"), nodes.first
  end

  def test_call_with_negated_kw3
    nodes = query_pattern("foo(!bar: 1, baz: true)", "foo(baz: true)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(baz: true)"), nodes.first
  end

  def test_call_with_negated_kw4
    nodes = query_pattern("foo(!bar: 1)", "foo()")
    assert_equal 1, nodes.size
    assert_equal ruby("foo()"), nodes.first
  end

  def test_call_with_negated_kw5
    nodes = query_pattern("foo(!bar: _)", "foo(params)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(params)"), nodes.first
  end

  def test_call_with_rest_and_kw
    nodes = query_pattern("foo(_, ..., key: _, ...)", "foo(1); foo(2, key: 3); foo(key: 4); foo(1,2)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(2, key: 3)"), nodes.first
  end

  def test_call_with_block_pass
    nodes = query_pattern("map(&:id)", "foo.map(&:id)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo.map(&:id)"), nodes.first
  end

  def test_call_with_names
    node = E::Send.new(name: [:foo, :bar, /baz/], args: nil, receiver: E::Any.new, block: nil)
    assert node.test_node(ruby("a.foo()"))
    assert node.test_node(ruby("a.bar()"))
    assert node.test_node(ruby("a.foo_bar_baz()"))
    refute node.test_node(ruby("a.test()"))
  end

  def test_call_without_receiver
    nodes = query_pattern("foo", "foo; bar.foo")
    assert_equal 2, nodes.size
  end

  def test_call_with_any_receiver
    nodes = query_pattern("_.foo", "foo; bar.foo")
    assert_equal 1, nodes.size
    assert_equal ruby("bar.foo"), nodes.first
  end

  def test_vcall
    # Vcall pattern matches with local variable
    nodes = query_pattern("foo", "foo = 1; foo.bar")
    assert_equal 1, nodes.size
    assert_equal :lvar, nodes.first.type
    assert_equal :foo, nodes.first.children.first
  end

  def test_vcall2
    # Vcall pattern matches with method call
    nodes = query_pattern("foo", "foo(1,2,3)")
    assert_equal 1, nodes.size
    assert_equal ruby("foo(1,2,3)"), nodes.first
  end

  def test_vcall3
    # If lvar is receiver, it matches
    nodes = query_pattern("foo", "foo = 1; foo.bar()")
    assert_equal 1, nodes.size
    assert_equal ruby("foo = 1; foo").children.last, nodes.first
  end

  def test_vcall4
    # If lvar is not a receiver, it doesn't match
    nodes = query_pattern("foo", "foo = 1; f.bar(foo)")
    assert_empty nodes
  end

  def test_dstr
    nodes = query_pattern(":dstr:", 'foo("#{1+2}")')
    assert_equal 1, nodes.size
    assert_equal ruby('"#{1+2}"'), nodes.first
  end

  def test_without_block_option
    nodes = query_pattern("foo()", "foo() { foo() }")
    assert_equal 2, nodes.size
  end

  def test_with_block
    nodes = query_pattern("foo() {}", "foo do foo() end")
    assert_equal 1, nodes.size
    assert_equal ruby("foo() do foo() end"), nodes.first
  end

  def test_without_block
    nodes = query_pattern("foo() !{}", "foo do foo() end")
    assert_equal 1, nodes.size
    assert_equal ruby("foo()"), nodes.first
  end

  def test_regexp
    nodes = query_pattern(":regexp:", "[/1/, /#{2}/, 3]")
    assert_equal 2, nodes.size
    assert_equal [ruby("/1/"), ruby("/#{2}/")], nodes
  end

  def test_any_receiver1
    nodes = query_pattern("f...g", "f.g")
    assert_equal [ruby("f.g")], nodes
  end

  def test_any_receiver2
    nodes = query_pattern("f...h", "f.g.h")
    assert_equal [ruby("f.g.h")], nodes
  end

  def test_any_receiver3
    nodes = query_pattern("g...h", "f(g).h")
    assert_equal [], nodes
  end

  def test_any_receiver4
    nodes = query_pattern("a...b...c", "[a.c.b.d.c]")
    assert_equal [ruby("a.c.b.d.c")], nodes
  end

  def test_any_receiver5
    nodes = query_pattern("a...b", "[a.b.b]")
    assert_equal Set.new([ruby("a.b.b"), ruby("a.b")]), Set.new(nodes)
  end

  def test_self
    nodes = query_pattern("self.f", "f(); self.f(); foo.f()")
    assert_equal Set.new([ruby("self.f"), ruby("f()")]), Set.new(nodes)
  end

  def test_string_value
    nodes = query_pattern("has_many(:symbol: as 'children)", "has_many(:children); has_many(:repositories)", where: { children: [:children] })
    assert_equal Set.new([ruby("has_many :children")]), Set.new(nodes)
  end

  def test_conditional_if
    nodes = query_pattern('foo [conditional]', 'if foo; bar; end')
    assert_equal 1, nodes.size
    assert_equal ruby('foo'), nodes.first
  end

  def test_conditional_while
    nodes = query_pattern('foo [conditional]', 'while foo; bar; end')
    assert_equal 1, nodes.size
    assert_equal ruby('foo'), nodes.first
  end

  def test_conditional_and
    nodes = query_pattern('foo [conditional]', 'foo && bar')
    assert_equal 1, nodes.size
    assert_equal ruby('foo'), nodes.first
  end

  def test_conditional_or
    nodes = query_pattern('foo [conditional]', 'foo || bar')
    assert_equal 1, nodes.size
    assert_equal ruby('foo'), nodes.first
  end

  def test_conditional_csend
    nodes = query_pattern('foo [conditional]', 'foo&.bar')
    assert_equal 1, nodes.size
    assert_equal ruby('foo'), nodes.first
  end
end
