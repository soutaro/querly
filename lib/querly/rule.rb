module Querly
  class Rule
    attr_reader :id
    attr_reader :patterns

    attr_reader :messages
    attr_reader :justifications
    attr_reader :before_examples
    attr_reader :after_examples
    attr_reader :tags

    def initialize(id:, messages:, patterns:, tags:, before_examples:, after_examples:, justifications:)
      @id = id
      @patterns = patterns
      @messages = messages
      @justifications = justifications
      @before_examples = before_examples
      @after_examples = after_examples
      @tags = tags
    end

    class InvalidRuleHashError < StandardError; end

    def self.load(hash)
      id = hash["id"]
      raise InvalidRuleHashError, "id is missing" unless id

      patterns = Array(hash["pattern"]).map {|src| Pattern::Parser.parse(src) }
      raise InvalidRuleHashError, "pattern is missing" if patterns.empty?

      messages = Array(hash["message"])
      raise InvalidRuleHashError, "message is missing" if messages.empty?

      tags = Set.new(Array(hash["tags"]))
      before_examples = Array(hash["before"])
      after_examples = Array(hash["after"])
      justifications = Array(hash["justification"])

      Rule.new(id: id,
               messages: messages,
               patterns: patterns,
               tags: tags,
               before_examples: before_examples,
               after_examples: after_examples,
               justifications: justifications)
    end
  end
end
