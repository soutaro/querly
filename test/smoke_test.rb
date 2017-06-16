require_relative "test_helper"

require "open3"

class SmokeTest < Minitest::Test
  include UnificationAssertion

  def dirs
    @dirs ||= [root]
  end

  def push_dir(dir)
    dirs.push dir
    yield
  ensure
    dirs.pop
  end

  def sh!(*args, **options)
    output, _, status = Open3.capture3(*args, { chdir: dirs.last.to_s }.merge(options))

    unless status.success?
      raise "Failed: #{args.inspect}"
      puts output
    end

    output
  end

  def sh(*args, **options)
    Open3.capture3(*args, { chdir: dirs.last.to_s }.merge(options))
  end

  def root
    (Pathname(__dir__) + "../").realpath
  end

  def test_help
    sh!("bundle", "exec", "querly", "help")
  end

  def test_rules
    sh!("bundle", "exec", "querly", "--config=sample.yml", "rules")
  end

  def test_check
    sh!("bundle", "exec", "querly", "--config=sample.yml", "check", ".")
  end

  def test_test
    sh!("bundle", "exec", "querly", "--config=sample.yml", "test", ".")
  end

  def test_console
    sh!("bundle", "exec", "querly", "console", ".", stdin_data: ["help", "reload", "find self.p", "quit"].join("\n"))
  end

  def test_version
    sh!("bundle", "exec", "querly", "version")
  end

  def test_check_json_format
    push_dir root + "test/data/test1" do
      output = JSON.parse(sh!("bundle", "exec", "querly", "check", "--format=json", "."), symbolize_names: true)
      assert_unifiable({
                         issues: [
                           {
                             script: "script.rb",
                             location: { start: [1,0], end: [1,8] },
                             rule: {
                               id: "test1.rule1",
                               messages: ["Use foo.bar instead of foobar\n\nfoo.bar is not good.\n"],
                               justifications: ["Some reason", "Another reason"],
                               examples: [{ before: "foobar", after: "foobarbaz" }],
                             }
                           }
                         ],
                         errors: []
                       }, output)
    end
  end

  def test_check_json_format_with_not_a_config_file
    push_dir root + "test/data/test1" do
      out, err, status = sh("bundle", "exec", "querly", "check", "--format=json", "--config=no.such.config", ".")

      refute status.success?
      assert_match(/Configuration file no.such.config does not look a file./, err)
      assert_unifiable({ issues: [], errors: [] }, JSON.parse(out, symbolize_names: true))
    end
  end

  def test_run3
    push_dir root + "test/data/test2" do
      out, _, status = sh("bundle", "exec", "querly", "check", "--format=json", ".")

      assert status.success?

      # Syntax error recorded in errors
      assert_unifiable({
                         issues: [],
                         errors: [{ path: "script.rb", error: :_ }]
                       }, JSON.parse(out, symbolize_names: true))
    end
  end

  def test_run4
    push_dir root + "test/data/test3" do
      out, _, status = sh("bundle", "exec", "querly", "check", "--format=json", ".")

      assert status.success?
      assert_unifiable({
                         issues: [
                           {
                             script: "script.rb",
                             location: { start: [1, 0], end: [1, 4] },
                             rule: { id: "test.pppp", messages: :_, justifications: :_, examples: :_ }
                           },
                           {
                             script: "script.rb",
                             location: { start: [2, 0], end: [2, 5] },
                             rule: { id: "test.pppp", messages: :_, justifications: :_, examples: :_ }
                           },
                           {
                             script: "script.rb",
                             location: { start: [3, 0], end: [3, 6] },
                             rule: { id: "test.pppp", messages: :_, justifications: :_, examples: :_ }
                           },
                         ],
                         errors: []
                       }, JSON.parse(out, symbolize_names: true))
    end
  end
end
