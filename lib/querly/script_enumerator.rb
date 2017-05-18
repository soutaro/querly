module Querly
  class ScriptEnumerator
    attr_reader :paths
    attr_reader :config

    def initialize(paths:, config:)
      @paths = paths
      @config = config
    end

    def each(&block)
      if block_given?
        paths.each do |path|
          case
          when path.file?
            load_script_from_path path, &block
          when path.directory?
            enumerate_files_in_dir(path, &block)
          end
        end
      else
        self.enum_for :each
      end
    end

    @loaders = []

    def self.register_loader(pattern, loader)
      @loaders << [pattern, loader]
    end

    def self.find_loader(path)
      basename = path.basename.to_s
      @loaders.find {|pair| pair.first === basename }&.last
    end

    private

    def load_script_from_path(path, &block)
      preprocessor = preprocessors[path.extname]

      begin
        source = if preprocessor
                   preprocessor.run!(path.read)
                 else
                   path.read
                 end

        script = Script.new(path: path, node: Parser::CurrentRuby.parse(source, path.to_s))
      rescue StandardError, LoadError, Preprocessor::Error => exn
        script = exn
      end

      yield(path, script)
    end

    def preprocessors
      config&.preprocessors || {}
    end

    def enumerate_files_in_dir(path, &block)
      if path.basename.to_s =~ /\A\.[^\.]+/
        # skip hidden paths
        return
      end

      case
      when path.directory?
        path.children.each do |child|
          enumerate_files_in_dir child, &block
        end
      when path.file?

    
        extensions = %w[
          .rb .builder .fcgi .gemspec .god .jbuilder .jb .mspec .opal .pluginspec
          .podspec .rabl .rake .rbuild .rbw .rbx .ru .ruby .spec .thor .watchr
        ]
        basenames = %w[
          .irbrc .pryrc buildfile Appraisals Berksfile Brewfile Buildfile Capfile
          Cheffile Dangerfile Deliverfile Fastfile Gemfile Guardfile Jarfile Mavenfile
          Podfile Puppetfile Rakefile Snapfile Thorfile Vagabondfile Vagrantfile
        ]
        should_load_file = case
                           when extensions.include?(path.extname)
                             true
                           when basenames.include?(path.basename.to_s)
                             true
                           else
                             preprocessors.key?(path.extname)
                           end

        load_script_from_path(path, &block) if should_load_file
      end
    end
  end
end
