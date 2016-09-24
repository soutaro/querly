require "slim"

module Querly
  module Loader
    module Slim
      def self.load(path, source)
        ::Slim::Engine.new(file: path).call(source)
      end
    end

    ScriptEnumerator.register_loader /\.slim$/, Slim
  end
end
