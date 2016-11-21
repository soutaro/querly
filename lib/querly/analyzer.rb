module Querly
  class Analyzer
    attr_reader :config
    attr_reader :scripts
    attr_reader :rules_cache

    def initialize(config:)
      @config = config
      @scripts = []
      @rules_cache = {}
    end

    #
    # yields(script, rule, node_pair)
    #
    def run
      scripts.each do |script|
        rules = rules_for_path(script.path)
        each_subnode script.root_pair do |node_pair|
          rules.each do |rule|
            if rule.patterns.any? {|pattern| test_pair(node_pair, pattern) }
              yield script, rule, node_pair
            end
          end
        end
      end
    end

    def find(pattern)
      scripts.each do |script|
        each_subnode script.root_pair do |node_pair|
          if test_pair(node_pair, pattern)
            yield script, node_pair
          end
        end
      end
    end

    def test_pair(node_pair, pattern)
      pattern.expr =~ node_pair && pattern.test_kind(node_pair)
    end

    def each_subnode(node_pair, &block)
      return unless node_pair.node

      yield node_pair

      node_pair.children.each do |child|
        each_subnode child, &block
      end
    end

    def rules_for_path(path)
      relative_path = config.relative_path_from_root(path)
      checks = config.checks.select {|check| check.match?(path: relative_path) }

      if rules_cache.key?(checks)
        rules_cache[checks]
      else
        checks.flat_map(&:rules).inject(config.all_rules) do |rules, query|
          query.apply(current: rules, all: config.all_rules)
        end.tap do |rules|
          rules_cache[checks] = rules
        end
      end
    end
  end
end
