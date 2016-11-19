require_relative "test_helper"

class RuleTest < Minitest::Test
  Rule = Querly::Rule
  E = Querly::Pattern::Expr
  K = Querly::Pattern::Kind

  def test_load_rule
    rule = Rule.load(
      "id" => "foo.bar.baz",
      "pattern" => "@",
      "message" => "message1"
    )

    assert_equal "foo.bar.baz", rule.id
    assert_equal ["message1"], rule.messages
    assert_equal [E::Ivar.new(name: nil)], rule.patterns.map(&:expr)
    assert_equal Set.new, rule.tags
    assert_equal [], rule.before_examples
    assert_equal [], rule.after_examples
    assert_equal [], rule.justifications
  end

  def test_load_rule2
    rule = Rule.load(
      "id" => "foo.bar.baz",
      "pattern" => ["@", "_"],
      "message" => "message1",
      "tags" => ["tag1", "tag2"],
      "before" => ["foo", "bar"],
      "after" => ["baz", "a"],
      "justification" => ["some", "message"]
    )

    assert_equal "foo.bar.baz", rule.id
    assert_equal ["message1"], rule.messages
    assert_equal [E::Ivar.new(name: nil), E::Any.new], rule.patterns.map(&:expr)
    assert_equal Set.new(["tag1", "tag2"]), rule.tags
    assert_equal ["foo", "bar"], rule.before_examples
    assert_equal ["baz", "a"], rule.after_examples
    assert_equal ["some", "message"], rule.justifications
  end

  def test_load_rule_raises_on_pattern_syntax_error
    assert_raises Racc::ParseError do
      Rule.load(
        "id" => "foo.bar.baz",
        "pattern" => "1+2",
        "message" => "message1"
      )
    end
  end

  def test_load_rule_raises_without_id
    exn = assert_raises Rule::InvalidRuleHashError do
      Rule.load("pattern" => "_", "message" => "message1")
    end

    assert_equal "id is missing", exn.message
  end

  def test_load_rule_raises_without_pattern
    exn = assert_raises Rule::InvalidRuleHashError do
      Rule.load("id" => "id1", "message" => "hello world")
    end

    assert_equal "pattern is missing", exn.message
  end

  def test_load_rule_raises_without_message
    exn = assert_raises Rule::InvalidRuleHashError do
      Rule.load("id" => "id1", "pattern" => "foobar")
    end

    assert_equal "message is missing", exn.message
  end
end
