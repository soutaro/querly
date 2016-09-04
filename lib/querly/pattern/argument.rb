module Querly
  module Pattern
    module Argument
      class Base
        attr_reader :tail

        def initialize(tail:)
          @tail = tail
        end
      end

      class AnySeq < Base
        def initialize(tail: nil)
          super(tail: tail)
        end
      end

      class Expr < Base
        attr_reader :expr

        def initialize(expr:, tail:)
          @expr = expr
          super(tail: tail)
        end
      end

      class KeyValue < Base
        attr_reader :key
        attr_reader :value
        attr_reader :negated

        def initialize(key:, value:, tail:, negated: false)
          @key = key
          @value = value
          @negated = negated

          super(tail: tail)
        end
      end
    end
  end
end
