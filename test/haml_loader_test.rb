require_relative "test_helper"

class HamlLoaderTest < Minitest::Test
  def test_loader
    script = Querly::Loader::Haml.load(Pathname("foo.haml"), <<HAML)
%div= render :foo, :bar
HAML

    assert_instance_of Parser::AST::Node, Parser::CurrentRuby.parse(script)
  end
end
