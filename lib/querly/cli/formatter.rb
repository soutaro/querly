module Querly
  class CLI
    module Formatter
      class Base
        include Concerns::BacktraceFormatter

        # Called when analyzer started
        def start; end

        # Called when config is successfully loaded
        def config_load(config); end

        # Called when failed to load config
        # Exit(status == 0) after the call
        def config_error(path, error); end

        # Called when script is successfully loaded
        def script_load(script); end

        # Called when failed to load script
        # Continue after the call
        def script_error(path, error); end

        # Called when issue is found
        def issue_found(script, rule, pair); end

        # Called on other error
        # Abort(status != 0) after the call
        def fatal_error(error)
          STDERR.puts Rainbow("Fatal error: #{error}").red
          STDERR.puts "Backtrace:"
          STDERR.puts format_backtrace(error.backtrace)
        end

        # Called on exit/abort
        def finish; end
      end

      class Text < Base
        def config_error(path, error)
          STDERR.puts Rainbow("Failed to load configuration: #{path}").red
          STDERR.puts error
          STDERR.puts "Backtrace:"
          STDERR.puts format_backtrace(error.backtrace)
        end

        def script_error(path, error)
          STDERR.puts Rainbow("Failed to load script: #{path}").red
          STDERR.puts error.inspect
        end

        def issue_found(script, rule, pair)
          path = script.path.to_s
          src = Rainbow(pair.node.loc.expression.source.split(/\n/).first).red
          line = pair.node.loc.first_line
          col = pair.node.loc.column
          message = rule.messages.first.split(/\n/).first

          STDOUT.puts "#{path}:#{line}:#{col}\t#{src}\t#{message}"
        end
      end

      class JSON < Base
        def initialize
          @issues = []
          @script_errors = []
          @config_errors = []
          @fatal = nil
        end

        def config_error(path, error)
          @config_errors << [path, error]
        end

        def script_error(path, error)
          @script_errors << [path, error]
        end

        def issue_found(script, rule, pair)
          @issues << [script, rule, pair]
        end

        def finish
          STDOUT.print as_json.to_json
        end

        def fatal_error(error)
          super
          @fatal = error
        end

        def as_json
          case
          when @fatal
            # Fatal error found
            {
              fatal_error: {
                message: @fatal.inspect,
                backtrace: @fatal.backtrace
              }
            }
          when !@config_errors.empty?
            # Error found during config load
            {
              config_errors: @config_errors.map {|(path, error)|
                {
                  path: path.to_s,
                  error: {
                    message: error.inspect,
                    backtrace: error.backtrace
                  }
                }
              }
            }
          else
            # Successfully checked
            {
              issues: @issues.map {|(script, rule, pair)|
                {
                  script: script.path.to_s,
                  rule: {
                    id: rule.id,
                    messages: rule.messages,
                    justifications: rule.justifications,
                  },
                  location: {
                    start: [pair.node.loc.first_line, pair.node.loc.column],
                    end: [pair.node.loc.last_line, pair.node.loc.last_column]
                  }
                }
              },
              errors: @script_errors.map {|path, error|
                {
                  path: path.to_s,
                  error: {
                    message: error.inspect,
                    backtrace: error.backtrace
                  }
                }
              }
            }
          end
        end
      end
    end
  end
end
