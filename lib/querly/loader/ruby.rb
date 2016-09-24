module Querly
  module Loader
    module Ruby
      def self.load(path, source)
        path.read
      end
    end
  end

  ScriptEnumerator.register_loader /\.rb$/, Loader::Ruby
  ScriptEnumerator.register_loader /\.gemspec$/, Loader::Ruby
  ScriptEnumerator.register_loader /^Rakefile$/, Loader::Ruby
end

