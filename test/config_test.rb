require_relative "test_helper"

class ConfigTest < Minitest::Test
  Config = Querly::Config
  Preprocessor = Querly::Preprocessor

  def stderr
    @stderr ||= StringIO.new
  end

  def test_factory_config_returns_empty_config
    config = Config::Factory.new({}, root_dir: Pathname("/foo/bar"), stderr: stderr).config

    assert_instance_of Config, config
    assert_empty config.rules
    assert_empty config.preprocessors
    assert_equal Pathname("/foo/bar"), config.root_dir
  end

  def test_factory_config_resturns_config_with_rules
    config = Config::Factory.new(
      {
        "rules" => [
          {
            "id" => "rule.id",
            "pattern" => "_",
            "message" => "Hello world"
          }
        ],
        "preprocessor" => {
          ".slim" => "slimrb --compile"
        },
        "check" => [
          {
            "path" => "/test",
            "rules" => ["rails", "minitest"]
          },
          {
            "path" => "/test/integration",
            "rules" => ["capybara", { "except" => "minitest" }]
          }
        ]
      }, root_dir: Pathname("/foo/bar"), stderr: stderr
    ).config

    assert_instance_of Config, config
    assert_equal ["rule.id"], config.rules.map(&:id)
    assert_equal [".slim"], config.preprocessors.keys
    assert_equal Pathname("/foo/bar"), config.root_dir
  end

  def test_factory_config_prints_warning_on_tagging
    Config::Factory.new({ "tagging" => [] }, root_dir: Pathname("/foo/bar"), stderr: stderr).config

    assert_match /tagging is deprecated and ignored/, stderr.string
  end
end
