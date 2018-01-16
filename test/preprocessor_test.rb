require_relative "test_helper"

class PreprocessorTest < Minitest::Test
  Preprocessor = Querly::Preprocessor

  def with_temp_file(content)
    Tempfile.create("querly-preprocessor") do |io|
      io.write content
      io.close
      yield Pathname(io.path)
    end
  end

  def test_preprocessing_succeeded
    preprocessor = Preprocessor.new(ext: ".foo", command: "cat -n")

    target = with_temp_file(<<-EOS) do |path|
foo
bar
    EOS
      preprocessor.run!(path)
    end

    assert_equal(<<-EXPECTED, target)
     1\tfoo
     2\tbar
    EXPECTED
  end

  def test_preprocessing_failed
    preprocessor = Preprocessor.new(ext: ".foo", command: "grep XYZ")

    assert_raises Preprocessor::Error do
      with_temp_file(<<-EOS) do |path|
foo
bar
    EOS
        preprocessor.run!(path)
      end
    end
  end
end
