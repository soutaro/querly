require "thor"

module Querly
  class CLI < Thor
    option :config, default: "querly.yaml"

    desc "check [paths]", "Check paths based on configuration"
    def check(*paths)
      config_path = Pathname(options[:config])

      unless config_path.file?
        STDERR.puts <<-Message
Configuration file #{config_path} does not look a file.
Specify configuration file by --config option.
        Message
        exit 1
      end

      config = Config.new
      config.add_file Pathname(options[:config])

      analyzer = Analyzer.new
      analyzer.rules.concat config.rules

      ScriptEnumerator.new(paths: paths.map {|path| Pathname(path) }).each do |path|
        begin
          analyzer.scripts << Script.from_path(path)
        rescue => exn
          p exn
        end
      end

      analyzer.run do |script, rule, pair|
        path = script.path.to_s
        src = Rainbow(pair.node.loc.expression.source.split(/\n/).first).red
        line = pair.node.loc.first_line
        col = pair.node.loc.column
        message = rule.messages.first

        puts "#{path}:#{line}:#{col}\t#{src}\t#{message}"
      end
    end
  end
end
