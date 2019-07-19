# frozen_string_literal: true

module Querly
  class CLI
    class Find
      include Concerns::BacktraceFormatter

      attr_reader :pattern_str
      attr_reader :paths
      attr_reader :config
      attr_reader :threads

      def initialize(pattern:, paths:, config: nil, threads:)
        @pattern_str = pattern
        @paths = paths
        @config = config
        @threads = threads
      end

      def start
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
        STDOUT.puts "pattern: #{pattern_str}"
        STDOUT.puts "Backtrace:"
        STDOUT.puts format_backtrace(exn.backtrace)
      end

      def pattern
        Pattern::Parser.parse(pattern_str, where: {})
      end

      def analyzer
        return @analyzer if @analyzer

        @analyzer = Analyzer.new(config: config, rule: nil)

        ScriptEnumerator.new(paths: paths, config: config, threads: threads).each do |path, script|
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
    end
  end
end
