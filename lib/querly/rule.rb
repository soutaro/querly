module Querly
  class Rule
    class Example
      attr_reader :before
      attr_reader :after

      def initialize(before:, after:)
        @before = before
        @after = after
      end

      def ==(other)
        other.is_a?(Example) && other.before == before && other.after == after
      end
    end

    attr_reader :id
    attr_reader :patterns
    attr_reader :messages

    attr_reader :sources
    attr_reader :justifications
    attr_reader :before_examples
    attr_reader :after_examples
    attr_reader :examples
    attr_reader :tags

    def initialize(id:, messages:, patterns:, sources:, tags:, before_examples:, after_examples:, justifications:, examples:)
      @id = id
      @patterns = patterns
      @sources = sources
      @messages = messages
      @justifications = justifications
      @before_examples = before_examples
      @after_examples = after_examples
      @tags = tags
      @examples = examples
    end

    def match?(identifier: nil, tags: nil)
      if identifier
        unless id == identifier || id.start_with?(identifier + ".")
          return false
        end
      end

      if tags
        unless tags.subset?(self.tags)
          return false
        end
      end

      true
    end

    class InvalidRuleHashError < StandardError; end
    class PatternSyntaxError < StandardError; end

    def self.load(hash)
      id = hash["id"]
      raise InvalidRuleHashError, "id is missing" unless id

      srcs = case hash["pattern"]
             when Array
               hash["pattern"]
             when nil
               []
             else
               [hash["pattern"]]
             end

      raise InvalidRuleHashError, "pattern is missing" if srcs.empty?
      patterns = srcs.map.with_index do |src, index|
        case src
        when String
          subject = src
          where = {}
        when Hash
          subject = src['subject']
          where = Hash[src['where'].map {|k,v| [k.to_sym, translate_where(v)] }]
        end

        begin
          Pattern::Parser.parse(subject, where: where)
        rescue Racc::ParseError => exn
          raise PatternSyntaxError, "Pattern syntax error: rule=#{hash["id"]}, index=#{index}, pattern=#{Rainbow(subject.split("\n").first).blue}, where=#{where.inspect}: #{exn}"
        end
      end

      messages = Array(hash["message"])
      raise InvalidRuleHashError, "message is missing" if messages.empty?

      tags = Set.new(Array(hash["tags"]))
      examples = [hash["examples"]].compact.flatten.map do |example|
        raise(InvalidRuleHashError, "Example should have at least before or after, #{example.inspect}") unless example.key?("before") || example.key?("after")
        Example.new(before: example["before"], after: example["after"])
      end
      before_examples = Array(hash["before"])
      after_examples = Array(hash["after"])
      justifications = Array(hash["justification"])

      Rule.new(id: id,
               messages: messages,
               patterns: patterns,
               sources: srcs,
               tags: tags,
               before_examples: before_examples,
               after_examples: after_examples,
               justifications: justifications,
               examples: examples)
    end

    def self.translate_where(value)
      Array(value).map do |v|
        case v
        when /\A\/(.*)\/\Z/
          Regexp.new($1)
        else
          v
        end
      end
    end
  end
end
