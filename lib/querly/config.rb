module Querly
  class Config
    attr_reader :rules
    attr_reader :preprocessors
    attr_reader :root_dir
    attr_reader :checks

    def initialize(rules:, preprocessors:, root_dir:, checks:)
      @rules = rules
      @root_dir = root_dir
      @preprocessors = preprocessors
      @checks = checks
    end

    def self.load(hash, config_path:, root_dir:, stderr: STDERR)
      Factory.new(hash, config_path: config_path, root_dir: root_dir, stderr: stderr).config
    end

    def all_rules
      @all_rules ||= Set.new(rules)
    end

    def relative_path_from_root(path)
      path.absolute? ? path.relative_path_from(root_dir) : path.cleanpath
    end

    class Factory
      attr_reader :yaml
      attr_reader :root_dir
      attr_reader :stderr
      attr_reader :config_path

      def initialize(yaml, config_path:, root_dir:, stderr: STDERR)
        @yaml = yaml
        @config_path = config_path
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

        imports = Array(yaml["import"])
        imports.each do |import|
          if import["load"]
            load_pattern = Pathname(import["load"])
            load_pattern = config_path.parent + load_pattern if load_pattern.relative?

            Pathname.glob(load_pattern.to_s) do |path|
              stderr.puts "Loading rules from #{path}..."
              YAML.load(path.read).each do |hash|
                rules << Rule.load(hash)
              end
            end
          end
        end

        checks = Array(yaml["check"]).map {|hash| Check.load(hash) }

        Config.new(rules: rules, preprocessors: preprocessors, checks: checks, root_dir: root_dir)
      end
    end
  end
end
