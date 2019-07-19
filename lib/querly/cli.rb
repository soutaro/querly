require "thor"
require "json"

if ENV["NO_COLOR"]
  Rainbow.enabled = false
end

module Querly
  class CLI < Thor
    desc "check [paths]", "Check paths based on configuration"
    option :config, default: "querly.yml"
    option :root
    option :format, default: "text", type: :string, enum: %w(text json)
    option :rule, type: :string
    option :threads, default: Parallel.processor_count, type: :numeric
    def check(*paths)
      require 'querly/cli/formatter'

      formatter = case options[:format]
                  when "text"
                    Formatter::Text.new
                  when "json"
                    Formatter::JSON.new
                  end
      formatter.start

      threads = Integer(options[:threads])

      begin
        unless config_path.file?
          STDERR.puts <<-Message
Configuration file #{config_path} does not look a file.
Specify configuration file by --config option.
          Message
          exit 1
        end

        begin
          config = config(root_option: options[:root])
        rescue => exn
          formatter.config_error config_path, exn
        end

        analyzer = Analyzer.new(config: config, rule: options[:rule])

        ScriptEnumerator.new(paths: paths.empty? ? [Pathname.pwd] : paths.map {|path| Pathname(path) }, config: config, threads: threads).each do |path, script|
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
    option :config, default: "querly.yml"
    option :threads, default: Parallel.processor_count, type: :numeric
    def console(*paths)
      require 'querly/cli/console'
      home_path = if (path = ENV["QUERLY_HOME"])
                       Pathname(path)
                     else
                       Pathname(Dir.home) + ".querly"
                     end
      home_path.mkdir unless home_path.exist?
      config = config_path.file? ? config(root_option: nil) : nil
      threads = Integer(options[:threads])

      Console.new(
        paths: paths.empty? ? [Pathname.pwd] : paths.map {|path| Pathname(path) },
        history_path: home_path + "history",
        history_size: ENV["QUERLY_HISTORY_SIZE"]&.to_i || 1_000_000,
        config: config,
        threads: threads
      ).start
    end

    desc "find pattern [paths]", "Find for the pattern in given paths"
    option :config, default: "querly.yml"
    option :threads, default: Parallel.processor_count, type: :numeric
    def find(pattern, *paths)
      require 'querly/cli/find'

      config = config_path.file? ? config(root_option: nil) : nil
      threads = Integer(options[:threads])

      Find.new(
        pattern: pattern,
        paths: paths.empty? ? [Pathname.pwd] : paths.map {|path| Pathname(path) },
        config: config,
        threads: threads
      ).start
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

    def self.source_root
      File.join(__dir__, "../..")
    end

    include Thor::Actions

    desc "init", "Generate Querly config file (querly.yml)"
    def init()
      copy_file("template.yml", "querly.yml")
    end

    private

    def config(root_option:)
      root_path = root_option ? Pathname(root_option).realpath : config_path.parent.realpath

      yaml = YAML.load(config_path.read)
      Config.load(yaml, config_path: config_path, root_dir: root_path, stderr: STDERR)
    end

    def config_path
      [Pathname(options[:config]),
       Pathname("querly.yaml")].compact.find(&:file?) || Pathname(options[:config])
    end
  end
end
