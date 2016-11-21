require "optparse"

module Querly
  module PP
    class CLI
      attr_reader :argv
      attr_reader :command
      attr_reader :load_paths
      attr_reader :requires

      attr_reader :stdin
      attr_reader :stderr
      attr_reader :stdout

      def initialize(argv, stdin: STDIN, stdout: STDOUT, stderr: STDERR)
        @argv = argv
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr

        @load_paths = []
        @requires = []

        OptionParser.new do |opts|
          opts.banner = "Usage: #{opts.program_name} pp-name [options]"
          opts.on("-I dir") {|path| load_paths << path }
          opts.on("-r lib") {|rq| requires << rq }
        end.permute!(argv)

        @command = argv.shift&.to_sym
      end

      def load_libs
        load_paths.each do |path|
          $LOAD_PATH << path
        end

        requires.each do |lib|
          require lib
        end

      end

      def run
        available_commands = [:haml]

        if available_commands.include?(command)
          send :"run_#{command}"
        else
          stderr.puts "Unknown command: #{command}"
          stderr.puts "  available commands: #{available_commands.join(", ")}"
          exit 1
        end
      end

      def run_haml
        require "haml"
        load_libs

        source = stdin.read

        options = Haml::Options.new

        parser = Haml::Parser.new(source, options)
        parser.parse

        compiler = Haml::Compiler.new(options)
        compiler.compile(parser.root)

        stdout.print compiler.precompiled
      end
    end
  end
end
