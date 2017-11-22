module Querly
  class Analyzer
    attr_reader :config
    attr_reader :scripts
    attr_reader :rule

    def initialize(config:, rule:)
      @config = config
      @scripts = []
      @rule = rule
    end

    #
    # yields(script, rule, node_pair)
    #
    def run
      scripts.each do |script|
        rules = config.rules_for_path(script.path)
        script.root_pair.each_subpair do |node_pair|
          rules.each do |rule|
            if rule.match?(identifier: self.rule)
              if rule.patterns.any? {|pattern| test_pair(node_pair, pattern) }
                yield script, rule, node_pair
              end
            end
          end
        end
      end
    end

    def find(pattern)
      scripts.each do |script|
        script.root_pair.each_subpair do |node_pair|
          if test_pair(node_pair, pattern)
            yield script, node_pair
          end
        end
      end
    end

    def test_pair(node_pair, pattern)
      pattern.expr =~ node_pair && pattern.test_kind(node_pair)
    end
  end
end
