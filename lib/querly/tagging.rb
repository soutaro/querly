module Querly
  class Tagging
    attr_reader :path_pattern
    attr_reader :tags_set

    def initialize(path_pattern:, tags_set:)
      @path_pattern = path_pattern
      @tags_set = tags_set
    end

    def applicable?(script)
      return true unless path_pattern

      pattern_components = path_pattern.split('/')

      script_path = if script.path.absolute?
                      script.path
                    else
                      script.realpath
                    end
      path_components = script_path.to_s.split(File::Separator)

      path_components.each_cons(pattern_components.size) do |slice|
        if slice == pattern_components
          return true
        end
      end

      false
    end
  end
end
