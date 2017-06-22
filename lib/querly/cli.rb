require "thor"
require "json"

module Querly
  class CLI < Thor
    desc "check [paths]", "Check paths based on configuration"
    option :config, default: "querly.yml"
    option :root
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

        root_option = options[:root]
        root_path = root_option ? Pathname(root_option).realpath : config_path.parent.realpath

        config = begin
          yaml = YAML.load(config_path.read)
          Config.load(yaml, config_path: config_path, root_dir: root_path, stderr: STDERR)
        rescue => exn
          formatter.config_error config_path, exn
          exit
        end

        analyzer = Analyzer.new(config: config)

        ScriptEnumerator.new(paths: paths.empty? ? [Pathname.pwd] : paths.map {|path| Pathname(path) }, config: config).each do |path, script|
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
      Console.new(paths: paths.empty? ? [Pathname.pwd] : paths.map {|path| Pathname(path) }).start
    end

    desc "test", "Check configuration"
    option :config, default: "querly.yml"
    def test()
      require "querly/cli/test"
      exit Test.new(config_path: config_path).run
    end

    desc "rules", "Print loaded rules"
    option :config, default: "querly.yml"
    def rules(*ids)
      require "querly/cli/rules"
      Rules.new(config_path: config_path, ids: ids).run
    end

    desc "version", "Print version"
    def version
      puts "Querly #{VERSION}"
    end

    private

    def config_path
      [Pathname(options[:config]),
       Pathname("querly.yaml")].compact.find(&:file?) || Pathname(options[:config])
    end
  end
end
