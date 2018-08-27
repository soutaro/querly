require 'readline'

module Querly
  class CLI
    class Console
      include Concerns::BacktraceFormatter

      attr_reader :paths
      attr_reader :history_file
      attr_reader :history_size

      def initialize(paths:, history_file: Pathname(".querly_history"), history_size: 1_000_000)
        @paths = paths
        @history_file = history_file
        @history_size = history_size
      end

      def start
        puts <<-Message
Querly #{VERSION}, interactive console

        Message

        puts_commands

        STDOUT.print "Loading..."
        STDOUT.flush
        reload!
        STDOUT.puts " ready!"

        load_history if history_file
        start_loop
      end

      def reload!
        @analyzer = nil
        analyzer
      end

      def analyzer
        return @analyzer if @analyzer

        @analyzer = Analyzer.new(config: nil, rule: nil)

        ScriptEnumerator.new(paths: paths, config: nil).each do |path, script|
          case script
          when Script
            @analyzer.scripts << script
          when StandardError
            p path: path, script: script.inspect
            puts script.backtrace
          end
        end

        @analyzer
      end

      def start_loop
        while line = Readline.readline("> ", true)
          case line
          when "quit"
            exit
          when "reload!"
            STDOUT.print "reloading..."
            STDOUT.flush
            reload!
            STDOUT.puts " done"
          when /^find (.+)/
            begin
              pattern = Pattern::Parser.parse($1, where: {})

              count = 0

              analyzer.find(pattern) do |script, pair|
                path = script.path.to_s
                line_no = pair.node.loc.first_line
                range = pair.node.loc.expression
                start_col = range.column
                end_col = range.last_column

                src = range.source_buffer.source_lines[line_no-1]
                src = Rainbow(src[0...start_col]).blue +
                  Rainbow(src[start_col...end_col]).bright.blue.bold +
                  Rainbow(src[end_col..-1]).blue

                puts "  #{path}:#{line_no}:#{start_col}\t#{src}"

                count += 1
              end

              puts "#{count} results"
            rescue => exn
              STDOUT.puts Rainbow("Error: #{exn}").red
              STDOUT.puts "Backtrace:"
              STDOUT.puts format_backtrace(exn.backtrace)
            end
          else
            puts_commands
          end

          save_history if history_file
        end
      end

      def load_history
        history_file.readlines.each do |line|
          Readline::HISTORY.push(line.chomp)
        end
      rescue Errno::ENOENT
        # in the first time
      end

      def save_history
        while Readline::HISTORY.length > history_size
          Readline::HISTORY.shift
        end

        history_file.write(Readline::HISTORY.to_a.join("\n") + "\n")
      end

      def puts_commands
        puts <<-Message
Commands:
  - find PATTERN   Find PATTERN from given paths
  - reload!        Reload program from paths
  - quit

        Message
      end
    end
  end
end
