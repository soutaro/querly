require_relative "test_helper"

class CheckTest < Minitest::Test
  Check = Querly::Check
  Rule = Querly::Rule

  def root
    @root ||= Pathname("/root/path")
  end

  def test_match1
    check = Check.new(pattern: "foo", rules: [])

    assert check.match?(path: Pathname("foo/bar"))
    assert check.match?(path: Pathname("foo"))
    assert check.match?(path: Pathname("bar/foo"))
    assert check.match?(path: Pathname("bar/foo/baz"))

    refute check.match?(path: Pathname("foobar"))
    refute check.match?(path: Pathname("bar"))
    refute check.match?(path: Pathname("bazbar"))
  end

  def test_match2
    check = Check.new(pattern: "foo/bar", rules: [])

    assert check.match?(path: Pathname("foo/bar"))
    assert check.match?(path: Pathname("foo/bar/baz"))

    refute check.match?(path: Pathname("xyzzy/foo/bar"))
    refute check.match?(path: Pathname("foo/baz/bar"))
  end

  def test_match3
    check = Check.new(pattern: "foo/bar/", rules: [])

    assert check.match?(path: Pathname("foo/bar/baz"))

    refute check.match?(path: Pathname("foo/bar"))
    refute check.match?(path: Pathname("xyz/foo/bar/baz"))
  end

  def test_match4
    check = Check.new(pattern: "foo/", rules: [])

    assert check.match?(path: Pathname("foo/bar"))
    assert check.match?(path: Pathname("baz/foo/bar"))

    refute check.match?(path: Pathname("foo"))
    refute check.match?(path: Pathname("baz/foo"))
  end

  def test_match5
    check = Check.new(pattern: "/foo", rules: [])

    assert check.match?(path: Pathname("foo/bar"))
    assert check.match?(path: Pathname("foo"))

    refute check.match?(path: Pathname("baz/foo/bar"))
    refute check.match?(path: Pathname("baz/foo"))
  end

  def test_load
    check = Check.load('path' => "foo",
                       'rules' => [
                         "rails.models",
                         { "id" => "ruby", "tags" => ["foo", "bar"] },
                         { "append" => { "tags" => ["baz"] } },
                         { "only" => "minitest" },
                         { "except" => { "id" => "rspec", "tags" => "t1 t2" } },
                       ])

    assert_equal 5, check.rules.size

    # appending rule by id
    assert_equal Check::Query.new(:append, nil, "rails.models"), check.rules[0]
    # default operand is append
    assert_equal Check::Query.new(:append, Set.new(["foo", "bar"]), "ruby"), check.rules[1]
    # append by explicit tags
    assert_equal Check::Query.new(:append, Set.new(["baz"]), nil), check.rules[2]
    # only by implicit id
    assert_equal Check::Query.new(:only, nil, "minitest"), check.rules[3]
    # except by explicit id
    assert_equal Check::Query.new(:except, Set.new(["t1", "t2"]), "rspec"), check.rules[4]
  end

  def test_query_match
    rule = Rule.new(id: "ruby.pathname", messages: nil, patterns: nil, sources: nil, tags: Set.new(["tag1", "tag2"]), before_examples: [], after_examples: [], justifications: [])

    assert Check::Query.new(:append, nil, "ruby.pathname").match?(rule)
    assert Check::Query.new(:append, nil, "ruby").match?(rule)
    refute Check::Query.new(:append, nil, "ruby23").match?(rule)

    assert Check::Query.new(:append, Set.new(["tag1"]), nil).match?(rule)
    assert Check::Query.new(:append, Set.new(["tag1", "tag2"]), nil).match?(rule)
    refute Check::Query.new(:append, Set.new(["tag1", "foo"]), nil).match?(rule)

    assert Check::Query.new(:append, Set.new(["tag1"]), "ruby").match?(rule)
    refute Check::Query.new(:append, Set.new(["tag1"]), "ruby23").match?(rule)
    refute Check::Query.new(:append, Set.new(["tag1", "foo"]), "ruby").match?(rule)
  end

  def test_query_apply
    r1 = Rule.new(id: "ruby.pathname", messages: nil, patterns: nil, sources: nil, tags: Set.new(), before_examples: [], after_examples: [], justifications: [])
    r2 = Rule.new(id: "minitest.assert", messages: nil, patterns: nil, sources: nil, tags: Set.new(), before_examples: [], after_examples: [], justifications: [])
    all_rules = Set.new([r1, r2])

    assert_equal Set.new([r1, r2]), Check::Query.new(:append, nil, "ruby").apply(current: Set.new([r2]), all: all_rules)
    assert_equal Set.new([r2]), Check::Query.new(:except, nil, "ruby").apply(current: all_rules, all: all_rules)
    assert_equal Set.new([r1]), Check::Query.new(:only, nil, "ruby").apply(current: all_rules, all: all_rules)
  end
end
