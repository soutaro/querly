module Querly
  class Rule
    attr_reader :id
    attr_reader :patterns

    attr_reader :messages
    attr_reader :justifications
    attr_reader :good_examples
    attr_reader :bad_examples
    attr_reader :tags
    attr_reader :scope

    def initialize(id:, scope: :nil)
      @id = id
      @scope = scope

      @patterns = []
      @messages = []
      @justifications = []
      @good_examples = []
      @bad_examples = []
      @tags = []
      @scope = scope
    end
  end
end
