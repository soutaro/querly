require_relative "test_helper"

class AnalyzerTest < Minitest::Test
  Analyzer = Querly::Analyzer
  Config = Querly::Config

  def stderr
    @stderr ||= StringIO.new
  end

  def root_dir
    Pathname("/foo/bar/baz")
  end

  def test_analyzer_rules_for_path
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
    analyzer = Analyzer.new(config: config)

    assert_equal ["rule1", "rule2", "rule3", "rule4"], analyzer.rules_for_path(root_dir + "foo.rb").map(&:id)
    assert_equal ["rule2"], analyzer.rules_for_path(root_dir + "test/foo.rb").map(&:id)
    assert_equal ["rule2", "rule3"], analyzer.rules_for_path(root_dir + "test/unit/foo.rb").map(&:id)
  end
end
