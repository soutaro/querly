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
    assert_equal [], rule.examples
    assert_equal [], rule.justifications
  end

  def test_load_rule3
    rule = Rule.load(
      "id" => "foo.bar.baz",
      "pattern" => ["@", "_"],
      "message" => "message1",
      "tags" => ["tag1", "tag2"],
      "examples" => { "before" => "foo", "after" => "bar"},
      "justification" => ["some", "message"]
    )

    assert_equal "foo.bar.baz", rule.id
    assert_equal ["message1"], rule.messages
    assert_equal [E::Ivar.new(name: nil), E::Any.new], rule.patterns.map(&:expr)
    assert_equal Set.new(["tag1", "tag2"]), rule.tags
    assert_equal [Rule::Example.new(before: "foo", after: "bar")], rule.examples
    assert_equal ["some", "message"], rule.justifications
  end

  def test_load_rule2
    rule = Rule.load(
      "id" => "foo.bar.baz",
      "pattern" => ["@", "_"],
      "message" => "message1",
      "tags" => ["tag1", "tag2"],
      "examples" => [{ "before" => "foo", "after" => "bar"},
                     { "before" => "foo" },
                     { "after" => "bar" }],
      "justification" => ["some", "message"]
    )

    assert_equal "foo.bar.baz", rule.id
    assert_equal ["message1"], rule.messages
    assert_equal [E::Ivar.new(name: nil), E::Any.new], rule.patterns.map(&:expr)
    assert_equal Set.new(["tag1", "tag2"]), rule.tags
    assert_equal [Rule::Example.new(before: "foo", after: "bar"),
                  Rule::Example.new(before: "foo", after: nil),
                  Rule::Example.new(before: nil, after: "bar")], rule.examples
    assert_equal ["some", "message"], rule.justifications
  end

  def test_load_rule_before_and_after_examples
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
    assert_equal [], rule.examples
    assert_equal ["foo", "bar"], rule.before_examples
    assert_equal ["baz", "a"], rule.after_examples
    assert_equal ["some", "message"], rule.justifications
  end

  def test_load_rule_raises_on_pattern_syntax_error
    exn = assert_raises Rule::PatternSyntaxError do
      Rule.load("id" => "id1", "pattern" => "syntax error")
    end

    assert_match(/Pattern syntax error: rule=id1, index=0, pattern=syntax error, where={}:/, exn.message)
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

  def test_load_including_pattern_with_where_clause
    rule = Rule.load("id" => "id1", "message" => "message", "pattern" => { 'subject' => "'g()'", 'where' => { 'g' => ["foo", "/bar/"] } })
    assert_equal 1, rule.patterns.size

    pattern = rule.patterns.first
    assert_equal ["foo", /bar/], pattern.expr.name
  end

  def test_load_rule_raises_exception_on_invalid_example
    assert_raises Rule::InvalidRuleHashError do
      Rule.load("id" => "id1", "message" => "message", "pattern" => { 'subject' => "'g()'", 'where' => { 'g' => ["foo", "/bar/"] } }, "examples" => [{}])
    end
  end

  def test_translate_where
    w = YAML.load(<<-YAML)
- foo
- /bar/
- :baz
- 1
- 2.0
    YAML

    assert_equal ["foo", /bar/, :baz, 1, 2.0], Rule.translate_where(w)
  end
end
