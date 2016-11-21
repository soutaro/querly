module Querly
  class Check
    Query = Struct.new(:opr, :tags, :identifier) do
      def apply(current:, all:)
        case opr
        when :append
          current.union(all.select {|rule| match?(rule) })
        when :except
          current.reject {|rule| match?(rule) }.to_set
        when :only
          all.select {|rule| match?(rule) }.to_set
        end
      end

      def match?(rule)
        rule.match?(identifier: identifier, tags: tags)
      end
    end

    attr_reader :patterns
    attr_reader :rules

    def initialize(pattern:, rules:)
      @rules = rules

      @has_trailing_slash = pattern.end_with?("/")
      @has_middle_slash = /\/./ =~ pattern

      @patterns = []

      pattern.sub!(/\A\//, '')

      case
      when has_trailing_slash? && has_middle_slash?
        patterns << File.join(pattern, "**")
      when has_trailing_slash?
        patterns << File.join(pattern, "**")
        patterns << File.join("**", pattern, "**")
      when has_middle_slash?
        patterns << pattern
        patterns << File.join(pattern, "**")
      else
        patterns << pattern
        patterns << File.join("**", pattern)
        patterns << File.join(pattern, "**")
        patterns << File.join("**", pattern, "**")
      end
    end

    def has_trailing_slash?
      @has_trailing_slash
    end

    def has_middle_slash?
      @has_middle_slash
    end

    def self.load(hash)
      pattern = hash["path"]

      rules = Array(hash["rules"]).map do |rule|
        case rule
        when String
          parse_rule_query(:append, rule)
        when Hash
          case
          when rule["append"]
            parse_rule_query(:append, rule["append"])
          when rule["except"]
            parse_rule_query(:except, rule["except"])
          when rule["only"]
            parse_rule_query(:only, rule["only"])
          else
            parse_rule_query(:append, rule)
          end
        end
      end

      self.new(pattern: pattern, rules: rules)
    end

    def self.parse_rule_query(opr, query)
      case query
      when String
        Query.new(opr, nil, query)
      when Hash
        if query['tags']
          ts = query['tags']
          if ts.is_a?(String)
            ts = ts.split
          end
          tags = Set.new(ts)
        end
        identifier = query['id']

        Query.new(opr, tags, identifier)
      end
    end

    def match?(path:)
      patterns.any? {|pat| File.fnmatch?(pat, path.to_s) }
    end
  end
end
