module Querly
  module Pattern
    module Kind
      class Base
        attr_reader :expr

        def initialize(expr:)
          @expr = expr
        end
      end

      module Negatable
        attr_reader :negated

        def initialize(expr:, negated:)
          @negated = negated
          super(expr: expr)
        end
      end

      class Any < Base
        def test_kind(pair)
          true
        end
      end

      class Conditional < Base
        include Negatable

        def test_kind(pair)
          !negated == !!conditional?(pair)
        end

        def conditional?(pair)
          node = pair.node
          parent = pair.parent&.node

          case parent&.type
          when :if
            node.equal? parent.children.first
          when :while
            node.equal? parent.children.first
          when :and
            node.equal? parent.children.first
          when :or
            node.equal? parent.children.first
          else
            false
          end
        end
      end

      class Discarded < Base
        include Negatable

        def test_kind(pair)
          !negated == !!discarded?(pair)
        end

        def discarded?(pair)
          node = pair.node
          parent = pair.parent&.node

          case parent&.type
          when :begin
            if node.equal? parent.children.last
              discarded? pair.parent
            else
              true
            end
          else
            false
          end
        end
      end
    end
  end
end
