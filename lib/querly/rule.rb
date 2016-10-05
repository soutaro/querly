module Querly
  class Rule
    attr_reader :id
    attr_reader :patterns

    attr_reader :messages
    attr_reader :justifications
    attr_reader :before_examples
    attr_reader :after_examples
    attr_reader :tags
    attr_reader :scope

    def initialize(id:, scope: :nil)
      @id = id
      @scope = scope

      @patterns = []
      @messages = []
      @justifications = []
      @before_examples = []
      @after_examples = []
      @tags = Set.new
      @scope = scope
    end
  end
end
