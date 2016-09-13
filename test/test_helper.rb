$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'querly'

require 'minitest/autorun'

module TestHelper
  E = Querly::Pattern::Expr
  A = Querly::Pattern::Argument

  def parse(src)
    Querly::Pattern::Parser.parse(src)
  end

  def query_pattern(pattern, src)
    pat = Querly::Pattern::Parser.parse(pattern)

    analyzer = Querly::Analyzer.new()
    analyzer.scripts << Querly::Script.from_source(src, "(input)")

    [].tap do |result|
      analyzer.find(pat) do |script, pair|
        result << pair.node
      end
    end
  end
end
