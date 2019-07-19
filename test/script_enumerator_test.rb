require_relative "test_helper"

class ScriptEnumeratorTest < Minitest::Test
  include TestHelper

  ScriptEnumerator = Querly::ScriptEnumerator
  Config = Querly::Config

  def test_parsing_ruby
    mktmpdir do |dir|
      config = Config.new(rules: [], preprocessors: {}, root_dir: dir, checks: [])
      e = ScriptEnumerator.new(paths: nil, config: config, threads: 1)

      ruby_path = dir + "foo.rb"
      ruby_path.write <<-EOR
def foo()
end
      EOR

      e.__send__(:load_script_from_path, ruby_path) do |path, script|
        assert_equal ruby_path, path
        assert_instance_of Querly::Script, script
      end
    end
  end

  def test_parse_error_ruby
    mktmpdir do |dir|
      config = Config.new(rules: [], preprocessors: {}, root_dir: dir, checks: [])
      e = ScriptEnumerator.new(paths: nil, config: config, threads: 1)

      ruby_path = dir + "foo.rb"
      ruby_path.write <<-EOR
def foo()
      EOR

      e.__send__(:load_script_from_path, ruby_path) do |path, script|
        assert_equal ruby_path, path
        assert_instance_of Parser::SyntaxError, script
      end
    end
  end

  def test_no_parse_error_on_invalid_utf8_sequence
    mktmpdir do |dir|
      config = Config.new(rules: [], preprocessors: {}, root_dir: dir, checks: [])
      e = ScriptEnumerator.new(paths: nil, config: config, threads: 1)

      ruby_path = dir + "foo.rb"
      ruby_path.write '"\xFF"'

      e.__send__(:load_script_from_path, ruby_path) do |path, script|
        assert_equal ruby_path, path
        assert_instance_of Querly::Script, script
      end
    end
  end
end
