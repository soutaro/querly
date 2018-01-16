module Querly
  class Preprocessor
    class Error < StandardError
      attr_reader :command
      attr_reader :status

      def initialize(command:, status:)
        @command = command
        @status = status
      end
    end

    attr_reader :ext
    attr_reader :command

    def initialize(ext:, command:)
      @ext = ext
      @command = command
    end

    def run!(path)
      stdout_read, stdout_write = IO.pipe

      output = ""

      reader = Thread.new do
        while (line = stdout_read.gets)
          output << line
        end
      end

      succeeded = system(command, in: path.to_s, out: stdout_write)
      stdout_write.close

      reader.join

      raise Error.new(status: $?, command: command) unless succeeded

      output
    end
  end
end
