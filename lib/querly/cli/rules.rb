module Querly
  class CLI
    class Rules
      attr_reader :config_path
      attr_reader :stdout
      attr_reader :ids

      def initialize(config_path:, ids:, stdout: STDOUT)
        @config_path = config_path
        @stdout = stdout
        @ids = ids
      end

      def config
        yaml = YAML.load(config_path.read)
        @config ||= Config.load(yaml, root_dir: config_path.parent.realpath)
      end

      def run
        rules = config.rules.select {|rule| test_rule(rule) }
        stdout.puts YAML.dump(rules.map {|rule| rule_to_yaml(rule) })
      end

      def test_rule(rule)
        if ids.empty?
          true
        else
          ids.any? {|id| rule.match?(identifier: id) }
        end
      end

      def rule_to_yaml(rule)
        { "id" => rule.id }.tap do |hash|
          singleton rule.sources do |a|
            hash["pattern"] = a
          end

          singleton rule.messages do |a|
            hash["message"] = a
          end

          empty rule.tags do |a|
            hash["tags"] = a
          end

          singleton rule.justifications do |a|
            hash["justification"] = a
          end

          singleton rule.before_examples do |a|
            hash["before"] = a
          end

          singleton rule.after_examples do |a|
            hash["after"] = a
          end
        end
      end

      def empty(array)
        unless array.empty?
          yield array.to_a
        end
      end

      def singleton(array)
        empty(array) do
          if array.length == 1
            yield array.first
          else
            yield array.to_a
          end
        end
      end
    end
  end
end
