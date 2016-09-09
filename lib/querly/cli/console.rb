require 'readline'

module Querly
  class CLI
    class Console
      attr_reader :paths

      def initialize(paths:)
        @paths = paths
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

        loop
      end

      def reload!
        @analyzer = nil
        analyzer
      end

      def analyzer
        return @analyzer if @analyzer

        @analyzer = Analyzer.new

        ScriptEnumerator.new(paths: paths).each do |path|
          begin
            @analyzer.scripts << Script.from_path(path)
          rescue => exn
            p exn
          end
        end

        @analyzer
      end

      def loop
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
              pattern = Pattern::Parser.parse($1)

              count = 0

              analyzer.find(pattern) do |script, pair|
                path = script.path.to_s
                line = pair.node.loc.first_line

                while true
                  parent = pair.parent

                  if parent && parent.node.loc.first_line == line
                    pair = pair.parent
                  else
                    break
                  end
                end

                src = Rainbow(pair.node.loc.expression.source.split(/\n/).first).blue
                col = pair.node.loc.column

                puts "  #{path}:#{line}:#{col}\t#{src}"

                count += 1
              end

              puts "#{count} results"
            rescue => exn
              STDOUT.puts exn.inspect
            end
          else
            puts_commands
          end
        end
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
