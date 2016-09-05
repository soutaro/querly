require_relative "test_helper"

class PatternParserTest < Minitest::Test
  E = Querly::Pattern::Expr
  A = Querly::Pattern::Argument

  def test_parser1
    pattern = Querly::Pattern::Parser.parse("foo.bar")

    assert_instance_of E::Send, pattern
    assert_equal :bar, pattern.name
    assert_instance_of A::AnySeq, pattern.args

    assert_instance_of E::Send, pattern.receiver
    assert_equal :foo, pattern.receiver.name
    assert_instance_of A::AnySeq, pattern.receiver.args
  end
end
