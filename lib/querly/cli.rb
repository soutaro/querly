require "thor"

module Querly
  class CLI < Thor
    option :config

    desc "query [paths]", "Run Querly on paths"
    def query(*paths)
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
        rule_id = rule.id
        src = pair.node.loc.expression.source.split(/\n/).first
        line = pair.node.loc.first_line
        col = pair.node.loc.column
        message = rule.messages.first

        puts "#{path}:#{line}:#{col}\t#{rule_id}\t#{src}\t#{message}"
      end
    end
  end
end
