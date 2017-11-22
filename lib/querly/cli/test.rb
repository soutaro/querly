module Querly
  class CLI
    class Test
      attr_reader :config_path
      attr_reader :stdout
      attr_reader :stderr

      def initialize(config_path:, stdout: STDOUT, stderr: STDERR)
        @config_path = config_path
        @stdout = stdout
        @stderr = stderr
        @success = true
      end

      def fail!
        @success = false
      end

      def failed?
        !@success
      end

      def run
        config = load_config

        unless config
          stdout.puts "There is nothing to test at #{config_path} ..."
          stdout.puts "Make a configuration and run test again!"
          return 1
        end

        validate_rule_uniqueness(config.rules)
        validate_rule_patterns(config.rules)

        failed? ? 1 : 0
      rescue => exn
        stderr.puts Rainbow("Fatal error:").red
        stderr.puts exn.inspect
        stderr.puts exn.backtrace.map {|x| "  " + x }.join("\n")

        1
      end

      def validate_rule_uniqueness(rules)
        ids = Set.new

        stdout.puts "Checking rule id uniqueness..."

        duplications = 0

        rules.each do |rule|
          unless ids.add?(rule.id)
            stdout.puts Rainbow("  Rule id #{rule.id} duplicated!").red
            duplications += 1
          end
        end

        fail! unless duplications == 0
      end

      def validate_rule_patterns(rules)
        stdout.puts "Checking rule patterns..."

        tests = 0
        false_positives = 0
        false_negatives = 0
        errors = 0

        rules.each do |rule|
          rule.before_examples.each.with_index(1) do |example, example_index|
            tests += 1

            begin
              unless rule.patterns.any? {|pat| test_pattern(pat, example, expected: true) }
                stdout.puts(Rainbow("  #{rule.id}").red + ":\t#{ordinalize example_index} *before* example didn't match with any pattern")
                false_negatives += 1
              end
            rescue Parser::SyntaxError
              errors += 1
              stdout.puts(Rainbow("  #{rule.id}").red + ":\tParsing failed for #{ordinalize example_index} *before* example")
            end
          end

          rule.after_examples.each.with_index(1) do |example, example_index|
            tests += 1

            begin
              unless rule.patterns.all? {|pat| test_pattern(pat, example, expected: false) }
                stdout.puts(Rainbow("  #{rule.id}").red + ":\t#{ordinalize example_index} *after* example matched with some of patterns")
                false_positives += 1
              end
            rescue Parser::SyntaxError
              errors += 1
              stdout.puts(Rainbow("  #{rule.id}") + ":\tParsing failed for #{ordinalize example_index} *after* example")
            end
          end

          rule.examples.each.with_index(1) do |example, index|
            if example.before
              tests += 1
              begin
                unless rule.patterns.any? {|pat| test_pattern(pat, example.before, expected: true) }
                  stdout.puts(Rainbow("  #{rule.id}").red + ":\tbefore of #{ordinalize index} example didn't match with any pattern")
                  false_negatives += 1
                end
              rescue Parser::SyntaxError
                errors += 1
                stdout.puts(Rainbow("  #{rule.id}").red + ":\tParsing failed on before of #{ordinalize index} example")
              end
            end

            if example.after
              tests += 1
              begin
                unless rule.patterns.all? {|pat| test_pattern(pat, example.after, expected: false) }
                  stdout.puts(Rainbow("  #{rule.id}").red + ":\tafter of #{ordinalize index} example matched with some of patterns")
                  false_positives += 1
                end
              rescue Parser::SyntaxError
                errors += 1
                stdout.puts(Rainbow("  #{rule.id}") + ":\tParsing failed on after of #{ordinalize index} example")
              end
            end
          end
        end

        stdout.puts "Tested #{rules.size} rules with #{tests} tests."
        if false_positives > 0 || false_negatives > 0 || errors > 0
          stdout.puts "  #{false_positives} examples found which should not match, but matched"
          stdout.puts "  #{false_negatives} examples found which should match, but didn't"
          stdout.puts "  #{errors} examples raised error"
          fail!
        else
          stdout.puts Rainbow("  All tests green!").green
        end
      end

      def test_pattern(pattern, example, expected:)
        analyzer = Analyzer.new(config: nil, rule: nil)

        found = false

        node = Parser::CurrentRuby.parse(example)
        NodePair.new(node: node).each_subpair do |pair|
          if analyzer.test_pair(pair, pattern)
            found = true
          end
        end

        found == expected
      end

      def load_config
        if config_path.file?
          yaml = YAML.load(config_path.read)
          Config.load(yaml, config_path: config_path, root_dir: config_path.parent.realpath, stderr: STDERR)
        end
      end

      def ordinalize(number)
        ActiveSupport::Inflector.ordinalize(number)
      end
    end
  end
end
