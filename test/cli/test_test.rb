require_relative "../test_helper"

class TestTest < Minitest::Test
  Test = Querly::CLI::Test
  Config = Querly::Config

  attr_accessor :stdout, :stderr

  def setup
    self.stdout = StringIO.new
    self.stderr = StringIO.new
  end

  def test_load_config_failure
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      nil
    end

    result = test.run

    assert_equal 1, result
    assert_match %r/There is nothing to test at querly\.yaml/, stdout.string
  end

  def test_rule_uniqueness
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.load(
        {
          "rules" =>
            [
              { "id" => "id1", "pattern" => "_", "message" => "hello" },
              { "id" => "id1", "pattern" => "_", "message" => "hello" },
              { "id" => "id2", "pattern" => "_", "message" => "hello" }
            ]
        },
        config_path: Pathname.pwd,
        root_dir: Pathname.pwd,
        stderr: stderr
      )
    end

    result = test.run

    assert_equal 1, result
    assert_match %r/Rule id id1 duplicated!/, stdout.string
    refute_match %r/Rule id id2 duplicated!/, stdout.string
  end

  def test_rule_patterns_pass
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.load(
        {
          "rules" => [
            {
              "id" => "id1",
              "pattern" => [
                "foo()",
                "foo(1)"
              ],
              "message" => "hello",
              "before" => ["self.foo()", "foo(1)"],
              "after" => ["self.foo(x)", "bar()"]
            },
          ]
        },
        config_path: Pathname.pwd,
        root_dir: Pathname.pwd,
        stderr: stderr
      )
    end

    result = test.run

    assert_equal 0, result
    assert_match %r/All tests green!/, stdout.string
  end

  def test_rule_patterns_before_after_fail
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.load(
        {
          "rules" => [
            {
              "id" => "id1",
              "pattern" => [
                "foo()",
                "foo(1)"
              ],
              "message" => "hello",
              "before" => ["self.foo(x)", "foo(1)"],
              "after" => ["self.foo()", "bar(1)"]
            },
          ]
        },
        config_path: Pathname.pwd,
        root_dir: Pathname.pwd,
        stderr: stderr
      )
    end

    result = test.run

    assert_equal 1, result
    assert_match %r/id1:\t1st \*before\* example didn't match with any pattern/, stdout.string
    assert_match %r/id1:\t1st \*after\* example matched with some of patterns/, stdout.string
    assert_match %r/1 examples found which should not match, but matched/, stdout.string
    assert_match %r/1 examples found which should match, but didn't/, stdout.string
  end

  def test_rule_patterns_example_fail
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.load(
        {
          "rules" => [
            {
              "id" => "id1",
              "pattern" => [
                "foo()",
                "foo(1)"
              ],
              "message" => "hello",
              "examples" => [{ "before" => "self.foo(1)", "after" => "self.foo(1)" },
                             { "before" => "foo(0)", "after" => "bar(1)" }
              ]
            },
          ]
        },
        config_path: Pathname.pwd,
        root_dir: Pathname.pwd,
        stderr: stderr
      )
    end

    result = test.run

    assert_equal 1, result
    assert_match %r/id1:\tafter of 1st example matched with some of patterns/, stdout.string
    assert_match %r/id1:\tbefore of 2nd example didn't match with any pattern/, stdout.string
    assert_match %r/1 examples found which should not match, but matched/, stdout.string
    assert_match %r/1 examples found which should match, but didn't/, stdout.string
  end

  def test_rule_patterns_error
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.load(
        {
          "rules" =>[
            {
              "id" => "id1",
              "pattern" => "_",
              "message" => "hello",
              "examples" => [{ "before" => "self.foo(", "after" => "1)" }]
            },
          ]
        },
        config_path: Pathname.pwd,
        root_dir: Pathname.pwd,
        stderr: stderr
      )
    end

    result = test.run

    assert_equal 1, result
    assert_match %r/2 examples raised error/, stdout.string
  end
end
