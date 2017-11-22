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

    def run!(source_code)
      stdin_read, stdin_write = IO.pipe
      stdout_read, stdout_write = IO.pipe

      writer = Thread.new do
        stdin_write.print source_code
        stdin_write.close
      end

      output = ""

      reader = Thread.new do
        while (line = stdout_read.gets)
          output << line
        end
      end

      succeeded = system(command, in: stdin_read, out: stdout_write)
      stdout_write.close

      writer.join
      reader.join

      raise Error.new(status: $?, command: command) unless succeeded

      output
    end
  end
end
