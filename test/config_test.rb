require_relative "test_helper"

class ConfigTest < Minitest::Test
  Config = Querly::Config
  Preprocessor = Querly::Preprocessor

  def test_load_rules
    config = Config.new
    config.load_rules({ "rules" => [
      {
        "id" => "test1",
        "pattern" => "foo",
        "message" => "message1"
      },
      {
        "id" => "test2",
        "pattern" => "foo.bar",
        "message" => "message2",
        "tags" => "foo"
      },
      {
        "id" => "test3",
        "pattern" => "foo.bar.baz",
        "message" => "message3",
        "tags" => ["foo", "bar"]
      }
    ]})

    # Load tags
    assert_equal Set.new(), config.rules[0].tags
    assert_equal Set.new(["foo"]), config.rules[1].tags
    assert_equal Set.new(["foo", "bar"]), config.rules[2].tags
  end

  def test_load_preprocessors
    config = Config.new
    config.load_preprocessors({
                                ".haml" => "haml -I lib -r foo_plugin",
                                ".slim" => "slim"
                              })

    haml_preprocessor = config.preprocessors[".haml"]
    assert_instance_of Preprocessor, haml_preprocessor
    assert_equal ".haml", haml_preprocessor.ext
    assert_equal "haml -I lib -r foo_plugin", haml_preprocessor.command

    slim_preprocessor = config.preprocessors[".slim"]
    assert_instance_of Preprocessor, slim_preprocessor
    assert_equal ".slim", slim_preprocessor.ext
    assert_equal "slim", slim_preprocessor.command
  end
end
