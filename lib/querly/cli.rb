require "thor"

module Querly
  class CLI < Thor
    desc "query [paths]", "Run Querly on paths"
    def query(*paths)
      analyzer = Analyzer.new

      analyzer.rules << Rule.new(id: "com.ubiregi.net_http",
                                 pattern: Pattern::Expr::Constant.new(path: [:Net, :HTTP])).tap do |rule|
        rule.messages << "Should not use Net::HTTP directly; consider using HTTPClient"
        rule.justifications << "You need special feature provided by Net::HTTP"
      end

      analyzer.rules << Rule.new(id: "com.ubiregi.delete_all",
                                 pattern: Pattern::Expr::Send.new(receiver: Pattern::Expr::Any.new(),
                                                                  name: :delete_all)).tap do |rule|
        rule.messages << "delete_all skips validations and callbacks"
        rule.justifications << "When deleting huge records, and"
        rule.justifications << "When you are sure you don't need validations and callbacks"
      end

      analyzer.rules << Rule.new(id: "com.ubiregi.transaction",
                                 pattern: Pattern::Expr::Send.new(receiver: Pattern::Expr::Any.new(),
                                                                  name: :transaction
                                                                  )).tap do |rule|
        rule.messages << "Should not use ActiveRecord::Base.transaction directly"
        rule.justifications << "When defining locking helpers, or"
        rule.justifications << "When you are sure you lock related records correctly"
      end

      analyzer.rules << Rule.new(
        id: "com.ubiregi.render404",
        pattern: Pattern::Expr::Send.new(
          receiver: Pattern::Expr::Any.new(),
          name: :render,
          args: Pattern::Argument::KeyValue.new(key: :status,
                                                value: Pattern::Expr::Literal.new(
                                                  type: :symbol,
                                                  value: :not_found
                                                ),
                                                tail: Pattern::Argument::AnySeq.new)
        )).tap do |rule|
        rule.messages << "Should not render status: :not_found directly but use render404 helper"
        rule.justifications << "When rendering non-default 404 response"
      end

      analyzer.rules << Rule.new(
        id: "com.ubiregi.save_without_validation",
        pattern: Pattern::Expr::Send.new(
          receiver: Pattern::Expr::Any.new(),
          name: :save,
          args: Pattern::Argument::KeyValue.new(key: :validate,
                                                value: Pattern::Expr::Literal.new(
                                                  type: :bool,
                                                  value: false
                                                ),
                                                tail: Pattern::Argument::AnySeq.new)
        )).tap do |rule|
        rule.messages << "Should not skip validation"
        rule.justifications << "When you are really sure the record always be valid"
        rule.justifications << "When you have good reason to skip validation"
      end

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
