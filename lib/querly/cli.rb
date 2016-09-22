require "thor"
require "json"

module Querly
  class CLI < Thor
    desc "check [paths]", "Check paths based on configuration"
    option :config, default: "querly.yaml"
    option :format, default: "text", type: :string, enum: %w(text json)
    def check(*paths)
      require 'querly/cli/formatter'

      formatter = case options[:format]
                  when "text"
                    Formatter::Text.new
                  when "json"
                    Formatter::JSON.new
                  end
      formatter.start

      begin
        config_path = Pathname(options[:config])

        unless config_path.file?
          STDERR.puts <<-Message
Configuration file #{config_path} does not look a file.
Specify configuration file by --config option.
          Message
          exit 1
        end

        config = Config.new
        begin
          config.add_file Pathname(options[:config])
        rescue => exn
          formatter.config_error Pathname(options[:config]), exn
          exit
        end

        analyzer = Analyzer.new
        analyzer.rules.concat config.rules

        ScriptEnumerator.new(paths: paths.map {|path| Pathname(path) }).each do |path|
          begin
            script = Script.from_path(path)
            analyzer.scripts << script

            formatter.script_load script
          rescue => exn
            formatter.script_error path, exn
          end
        end

        analyzer.run do |script, rule, pair|
          formatter.issue_found script, rule, pair
        end
      rescue => exn
        formatter.fatal_error exn
        exit 1
      ensure
        formatter.finish
      end
    end

    desc "console [paths]", "Start console for given paths"
    def console(*paths)
      require 'querly/cli/console'
      Console.new(paths: paths.map {|path| Pathname(path) }).start
    end
  end
end
