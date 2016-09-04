module Querly
  class Rule
    attr_reader :id
    attr_reader :pattern

    attr_reader :messages
    attr_reader :justifications
    attr_reader :good_examples
    attr_reader :bad_examples
    attr_reader :tags
    attr_reader :scope

    def initialize(id:, pattern:, scope: :nil)
      @id = id
      @pattern = pattern
      @scope = scope

      @messages = []
      @justifications = []
      @good_examples = []
      @bad_examples = []
      @tags = []
      @scope = scope
    end
  end
end
