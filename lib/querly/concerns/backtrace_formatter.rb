module Querly
  module Concerns
    module BacktraceFormatter
      def format_backtrace(backtrace, indent: 2)
        backtrace.map {|x| " "*indent + x }.join("\n")
      end
    end
  end
end
