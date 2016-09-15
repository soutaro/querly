$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'querly'

require 'minitest/autorun'

module TestHelper
  E = Querly::Pattern::Expr
  A = Querly::Pattern::Argument
  K = Querly::Pattern::Kind

  def parse_expr(src)
    Querly::Pattern::Parser.parse(src).expr
  end

  def parse_kinded(src)
    Querly::Pattern::Parser.parse(src)
  end

  def query_pattern(pattern, src)
    pat = parse_kinded(pattern)

    analyzer = Querly::Analyzer.new()
    analyzer.scripts << Querly::Script.from_source(src, "(input)")

    [].tap do |result|
      analyzer.find(pat) do |script, pair|
        result << pair.node
      end
    end
  end

  def ruby(src)
    Parser::CurrentRuby.parse(src)
  end
end
