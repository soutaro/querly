module Querly
  class Config
    attr_reader :rules
    attr_reader :paths
    attr_reader :preprocessors

    def initialize()
      @rules = []
      @paths = []
      @preprocessors = {}
    end

    def add_file(path)
      paths << path

      content = YAML.load(path.read)
      load_rules(content)

      if content["tagging"]
        STDERR.puts "tagging key is deprecated and just ignroed."
      end

      load_preprocessors(content["preprocessor"] || {})
    end

    def load_rules(yaml)
      yaml["rules"].each do |hash|
        rules << Rule.load(hash)
      end
    end

    def load_preprocessors(preprocessors)
      @preprocessors = preprocessors.each.with_object({}) do |(key, value), hash|
        hash[key] = Preprocessor.new(ext: key, command: value)
      end
    end
  end
end
