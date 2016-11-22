require_relative "test_helper"

class AnalyzerTest < Minitest::Test
  Analyzer = Querly::Analyzer
  Config = Querly::Config

  def stderr
    @stderr ||= StringIO.new
  end
end
