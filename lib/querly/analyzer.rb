module Querly
  class Analyzer
    attr_reader :rules
    attr_reader :scripts
    attr_reader :taggings

    def initialize(taggings:)
      @rules = []
      @scripts = []
      @taggings = taggings
    end

    #
    # yields(script, rule, node_pair)
    #
    def run
      scripts.each do |script|
        tagging = taggings.find {|tagging| tagging.applicable?(script) }

        each_subnode script.root_pair do |node_pair|
          rules.each do |rule|
            if applicable_rule?(tagging, rule)
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

    def applicable_rule?(tagging, rule)
      if tagging && !rule.tags.empty?
        tagging.tags_set.any? {|set| set.subset?(rule.tags) }
      else
        true
      end
    end

    def each_subnode(node_pair, &block)
      return unless node_pair.node

      yield node_pair

      node_pair.children.each do |child|
        each_subnode child, &block
      end
    end
  end
end
