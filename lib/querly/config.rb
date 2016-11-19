module Querly
  class Config
    attr_reader :rules
    attr_reader :preprocessors
    attr_reader :root_dir

    def initialize(rules:, preprocessors:, root_dir:)
      @rules = rules
      @root_dir = root_dir
      @preprocessors = preprocessors
    end

    def self.load(hash, root_dir:, stderr: STDERR)
      Factory.new(hash, root_dir: root_dir, stderr: stderr).config
    end

    class Factory
      attr_reader :yaml
      attr_reader :root_dir
      attr_reader :stderr

      def initialize(yaml, root_dir:, stderr: STDERR)
        @yaml = yaml
        @root_dir = root_dir
        @stderr = stderr
      end

      def config
        if yaml["tagging"]
          stderr.puts "tagging is deprecated and ignored"
        end

        rules = Array(yaml["rules"]).map {|hash| Rule.load(hash) }
        preprocessors = (yaml["preprocessor"] || {}).each.with_object({}) do |(key, value), hash|
          hash[key] = Preprocessor.new(ext: key, command: value)
        end

        Config.new(rules: rules, preprocessors: preprocessors, root_dir: root_dir)
      end
    end
  end
end
