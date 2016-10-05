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
      output, status = Open3.capture2({ 'RUBYOPT' => nil }, command, stdin_data: source_code)
      raise Error.new(status: status, command: command) unless status.success?
      output
    end
  end
end
