require "thor"
require "json"

module Querly
  class CLI < Thor
    desc "check [paths]", "Check paths based on configuration"
    option :config, default: "querly.yml"
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
        unless config_path.file?
          STDERR.puts <<-Message
Configuration file #{config_path} does not look a file.
Specify configuration file by --config option.
          Message
          exit 1
        end

        config = Config.new
        begin
          config.add_file config_path
        rescue => exn
          formatter.config_error config_path, exn
          exit
        end

        analyzer = Analyzer.new(taggings: config.taggings)
        analyzer.rules.concat config.rules

        ScriptEnumerator.new(paths: paths.map {|path| Pathname(path) }, preprocessors: config.preprocessors).each do |path, script|
          case script
          when Script
            analyzer.scripts << script
            formatter.script_load script
          when StandardError, LoadError
            formatter.script_error path, script
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

    private

    def config_path
      [Pathname(options[:config]),
       Pathname("querly.yaml")].compact.find(&:file?) || Pathname(options[:config])
    end
  end
end
