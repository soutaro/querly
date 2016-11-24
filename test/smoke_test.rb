require_relative "test_helper"

require "open3"

class SmokeTest < Minitest::Test
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
    output, status = Open3.capture2e(*args, { chdir: dirs.last.to_s }.merge(options))

    unless status.success?
      raise "Failed: #{args.inspect}"
      puts output
    end

    output
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
  end
end
