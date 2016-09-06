module Querly
  class Config
    attr_reader :rules
    attr_reader :paths

    def initialize()
      @rules = []
      @paths = []
    end

    def add_file(path)
      paths << path

      load_rules(YAML.load(path.read))
    end

    def load_rules(yaml)
      yaml["rules"].each do |hash|
        id = hash["id"]
        patterns = Array(hash["pattern"]).map {|src| Pattern::Parser.parse(src) }
        messages = Array(hash["message"])
        justifications = Array(hash["justification"])

        rule = Rule.new(id: id)
        rule.patterns.concat patterns
        rule.messages.concat messages
        rule.justifications.concat justifications

        rules << rule
      end
    end
  end
end
