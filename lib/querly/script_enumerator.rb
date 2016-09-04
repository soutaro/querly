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
            yield path
          when path.directory?
            enumerate_files_in_dir(path, &block)
          end
        end
      else
        self.enum_for :each
      end
    end

    private

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
        if is_ruby_file?(path)
          yield path
        end
      end
    end

    def is_ruby_file?(path)
      case
      when path.extname == ".rb"
        true
      when path.extname == ".gemspec"
        true
      when path.basename.to_s == "Rakefile"
        true
      end
    end
  end
end
