require_relative "test_helper"

class TaggingTest < Minitest::Test
  Tagging = Querly::Tagging
  Script = Querly::Script

  def test_applicable1
    tagging = Tagging.new(path_pattern: "test/models", tags_set: nil)

    assert tagging.applicable?(Script.new(path: Pathname("/foo/bar/test/models/foo_test.rb"), node: nil))
    assert tagging.applicable?(Script.new(path: Pathname("/foo/bar/test/models/foo/bar_test.rb"), node: nil))
    refute tagging.applicable?(Script.new(path: Pathname("/foo/bar/app/models/foo.rb"), node: nil))
    refute tagging.applicable?(Script.new(path: Pathname("/foo/bar/app/models/test.rb"), node: nil))
    refute tagging.applicable?(Script.new(path: Pathname("/foo/bar/test/integration/models/foo_test.rb"), node: nil))
  end

  def test_applicable2
    tagging = Tagging.new(path_pattern: nil, tags_set: nil)

    # Applicable for any path if pattern is nil
    assert tagging.applicable?(Script.new(path: Pathname("/foo/bar/test/models/foo_test.rb"), node: nil))
    assert tagging.applicable?(Script.new(path: Pathname("/foo/bar/test/models/foo/bar_test.rb"), node: nil))
  end
end

