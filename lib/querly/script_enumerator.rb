module Querly
  class ScriptEnumerator
    attr_reader :paths

    def initialize(paths:)
      @paths = paths
    end

    def each(&block)
      if block_given?
        paths.each do |path|
          case
          when path.file?
            load_script_from_path path, default_loader: Loader::Ruby, &block
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

    def load_script_from_path(path, default_loader: nil, &block)
      loader = self.class.find_loader(path) || default_loader

      if loader
        script = nil

        begin
          source = loader.load(path, path.read)
          script = Script.new(path: path, node: Parser::CurrentRuby.parse(source, path.to_s))
        rescue => exn
          script = exn
        end

        yield(path, script)
      end
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
        load_script_from_path(path, &block)
      end
    end
  end
end
