module Querly
  class Config
    attr_reader :rules
    attr_reader :paths
    attr_reader :taggings
    attr_reader :preprocessors

    def initialize()
      @rules = []
      @paths = []
      @taggings = []
      @preprocessors = {}
    end

    def add_file(path)
      paths << path

      content = YAML.load(path.read)
      load_rules(content)
      load_taggings(content)
      load_preprocessors(content["preprocessor"] || {})
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
        Array(hash["tags"]).each {|tag| rule.tags << tag }
        rule.before_examples.concat Array(hash["before"])
        rule.after_examples.concat Array(hash["after"])

        rules << rule
      end
    end

    def load_taggings(yaml)
      @taggings = Array(yaml["tagging"]).map {|hash|
        Tagging.new(path_pattern: hash["path"],
                    tags_set: Array(hash["tags"]).map {|string| Set.new(string.split) })
      }.sort_by {|tagging| -tagging.path_pattern.size }
    end

    def load_preprocessors(preprocessors)
      @preprocessors = preprocessors.each.with_object({}) do |(key, value), hash|
        hash[key] = Preprocessor.new(ext: key, command: value)
      end
    end
  end
end
