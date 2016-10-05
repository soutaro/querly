require_relative "test_helper"

class PreprocessorTest < Minitest::Test
  Preprocessor = Querly::Preprocessor

  def test_preprocessing_succeeded
    preprocessor = Preprocessor.new(ext: ".foo", command: "cat -n")

    target = preprocessor.run!(<<-EOS)
foo
bar
    EOS

    assert_equal(<<-EXPECTED, target)
     1\tfoo
     2\tbar
    EXPECTED
  end

  def test_preprocessing_failed
    preprocessor = Preprocessor.new(ext: ".foo", command: "grep XYZ")

    assert_raises Preprocessor::Error do
      preprocessor.run!(<<-EOS)
foo
bar
      EOS
    end
  end
end
