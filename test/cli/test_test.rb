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

    test.run

    assert_match /There is nothing to test at querly\.yaml/, stdout.string
  end

  def test_rule_uniqueness
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.new.tap do |config|
        config.load_rules("rules" =>[
          { "id" => "id1", "pattern" => "_", "message" => "hello" },
          { "id" => "id1", "pattern" => "_", "message" => "hello" },
          { "id" => "id2", "pattern" => "_", "message" => "hello" }
        ])
      end
    end

    test.run

    assert_match /Rule id id1 duplicated!/, stdout.string
    refute_match /Rule id id2 duplicated!/, stdout.string
  end

  def test_rule_patterns_pass
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.new.tap do |config|
        config.load_rules("rules" =>[
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
        ])
      end
    end

    test.run

    assert_match /All tests green!/, stdout.string
  end

  def test_rule_patterns_fail
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.new.tap do |config|
        config.load_rules("rules" =>[
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
        ])
      end
    end

    test.run

    assert_match /id1:\t0th \*before\* example didn't match with any pattern/, stdout.string
    assert_match /id1:\t0th \*after\* example matched with some of patterns/, stdout.string
    assert_match /1 examples found which should not match, but matched/, stdout.string
    assert_match /1 examples found which should match, but didn't/, stdout.string
  end

  def test_rule_patterns_error
    test = Test.new(config_path: Pathname("querly.yaml"), stdout: stdout, stderr: stderr)

    def test.load_config
      Config.new.tap do |config|
        config.load_rules("rules" =>[
          {
            "id" => "id1",
            "pattern" => "_",
            "message" => "hello",
            "before" => ["self.foo("],
            "after" => ["1)"]
          },
        ])
      end
    end

    test.run

    assert_match /2 examples raised error/, stdout.string
  end
end
