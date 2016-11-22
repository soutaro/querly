require_relative "test_helper"

class ConfigTest < Minitest::Test
  include TestHelper

  Config = Querly::Config
  Preprocessor = Querly::Preprocessor

  def stderr
    @stderr ||= StringIO.new
  end

  def test_factory_config_returns_empty_config
    config = Config::Factory.new({}, config_path: Pathname("/foo/bar"), root_dir: Pathname("/foo/bar"), stderr: stderr).config

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
      },
      config_path: Pathname("/foo/bar"),
      root_dir: Pathname("/foo/bar"),
      stderr: stderr
    ).config

    assert_instance_of Config, config
    assert_equal ["rule.id"], config.rules.map(&:id)
    assert_equal [".slim"], config.preprocessors.keys
    assert_equal Pathname("/foo/bar"), config.root_dir
  end

  def test_factory_config_prints_warning_on_tagging
    Config::Factory.new({ "tagging" => [] }, config_path: Pathname("/foo/bar"), root_dir: Pathname("/foo/bar"), stderr: stderr).config

    assert_match /tagging is deprecated and ignored/, stderr.string
  end

  def test_relative_path_from_root
    config = Config::Factory.new({}, config_path: Pathname("/foo/bar"), root_dir: Pathname("/foo/bar"), stderr: stderr).config

    # Relative path from root_dir
    assert_equal Pathname("a/b/c.rb"), config.relative_path_from_root(Pathname("a/b/c.rb"))
    assert_equal Pathname("a/b/c.rb"), config.relative_path_from_root(Pathname("a/b/../b/c.rb"))
    assert_equal Pathname("baz/Rakefile"), config.relative_path_from_root(Pathname("/foo/bar/baz/Rakefile"))

    # Nonsense...
    assert_equal Pathname("../x.rb"), config.relative_path_from_root(Pathname("../x.rb"))
    assert_equal Pathname("../../a/b/c.rb"), config.relative_path_from_root(Pathname("/a/b/c.rb"))
  end

  def test_loading_rules_from_file
    hash = { "import" => [
      { "load" => "foo.yml" },
      { "load" => "rules/*" }
    ]}

    with_config hash do |path|
      dir = path.parent

      (dir + "foo.yml").write(YAML.dump([{ "id" => "rule1", "pattern" => "_", "message" => "rule1" }]))
      (dir + "rules").mkpath
      (dir + "rules" + "1.yml").write(YAML.dump([{ "id" => "rule2", "pattern" => "_", "message" => "rule1" }]))
      (dir + "rules" + "2.yml").write(YAML.dump([
                                                   { "id" => "rule3", "pattern" => "_", "message" => "rule1" },
                                                   { "id" => "rule4", "pattern" => "_", "message" => "rule1" }
                                                 ]))

      config = Config.load(YAML.load(path.read), config_path: path, root_dir: path, stderr: stderr)

      assert_equal ["rule1", "rule2", "rule3", "rule4"], config.rules.map(&:id)
    end
  end

  def test_analyzer_rules_for_path
    root_dir = Pathname("/foo/bar")

    config = Config.load(
      {
        "rules" => [{ "id" => "rule1", "pattern" => "_", "message" => "" },
                    { "id" => "rule2", "pattern" => "_", "message" => "" },
                    { "id" => "rule3", "pattern" => "_", "message" => "" },
                    { "id" => "rule4", "pattern" => "_", "message" => "" }],
        "check" => [{ "path" => "/test", "rules" => [{ "only" => "rule2" }] },
                    { "path" => "/test/unit", "rules" => ["rule3"] }]
      },
      config_path: root_dir,
      root_dir: root_dir,
      stderr: stderr
    )

    assert_equal ["rule1", "rule2", "rule3", "rule4"], config.rules_for_path(root_dir + "foo.rb").map(&:id)
    assert_equal ["rule2"], config.rules_for_path(root_dir + "test/foo.rb").map(&:id)
    assert_equal ["rule2", "rule3"], config.rules_for_path(root_dir + "test/unit/foo.rb").map(&:id)
  end
end
