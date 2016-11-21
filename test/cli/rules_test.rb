require_relative "../test_helper"
require "querly/cli/rules"

class RulesTest < Minitest::Test
  include TestHelper

  def test_rules_command
    config = {
      "rules" => [
        {
          "id" => "foo.rule1",
          "message" => "Sample Message",
          "pattern" => "@_"
        },
        {
          "id" => "bar.rule2",
          "message" => ["foo", "bar"],
          "pattern" => ["@_", "foo"]
        }
      ]
    }

    with_config config do |path|
      rules = Querly::CLI::Rules.new(config_path: path, ids: ["foo"], stdout: stdout)
      rules.run

      assert_match(/foo\.rule1/, stdout.string)
      refute_match(/bar\.rule2/, stdout.string)
    end
  end
end
