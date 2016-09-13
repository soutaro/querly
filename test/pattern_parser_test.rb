require_relative "test_helper"

class PatternParserTest < Minitest::Test
  include TestHelper

  def test_parser1
    pattern = Querly::Pattern::Parser.parse("foo.bar")

    assert_instance_of E::Send, pattern
    assert_equal :bar, pattern.name
    assert_instance_of A::AnySeq, pattern.args

    assert_instance_of E::Send, pattern.receiver
    assert_equal :foo, pattern.receiver.name
    assert_instance_of A::AnySeq, pattern.receiver.args
  end

  def test_aaa
    # p Querly::Pattern::Parser.parse("foo(!foo: bar)")
  end

  def test_ivar
    pat = parse("@")
    assert_equal E::Ivar.new(name: nil), pat
  end

  def test_ivar_with_name
    pat = parse("@x_123A")
    assert_equal E::Ivar.new(name: :@x_123A), pat
  end

  def test_pattern
    pat = parse(":racc")
    assert_equal E::Literal.new(type: :symbol, value: :racc), pat
  end

  def test_constant
    pat = parse("E")
    assert_equal E::Constant.new(path: [:E]), pat
  end
end
