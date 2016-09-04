module Querly
  module Pattern
    module Expr
      class Base
        def =~(pair)
          test_node(pair.node)
        end

        def test_node(node)
          false
        end
      end

      class Any < Base
        def test_node(node)
          true
        end
      end

      class Not < Base
        attr_reader :pattern

        def initialize(pattern:)
          @pattern = pattern
        end

        def test_node(node)
          !pattern.test_node(node)
        end
      end

      class Constant < Base
        attr_reader :path

        def initialize(path:)
          @path = path
        end

        def test_node(node)
          if path
            test_constant node, path
          else
            node&.type == :const
          end
        end

        def test_constant(node, path)
          if node
            case node.type
            when :const
              parent = node.children[0]
              name = node.children[1]

              if name == path.last
                test_constant parent, path.take(path.count - 1)
              end
            when :cbase
              path.empty?
            end
          else
            path.empty?
          end
        end
      end

      class Nil < Base
        def test_node(node)
          node.type == :nil
        end
      end

      class Literal < Base
        attr_reader :type
        attr_reader :value

        def initialize(type:, value: nil)
          @type = type
          @value = value
        end

        def test_node(node)
          case node&.type
          when :int
            return false unless type == :int || type == :number
            if value
              value == node.children.first
            else
              true
            end

          when :float
            return false unless type == :float || type == :number
            if value
              value == node.children.first
            else
              true
            end

          when :true
            type == :bool && (value == nil || value == true)

          when :false
            type == :bool && (value == nil || value == false)

          when :str
            return false unless type == :string
            if value
              value == node.children.first
            else
              true
            end

          when :sym
            return false unless type == :symbol
            if value
              value == node.children.first
            else
              true
            end

          end
        end
      end

      class Send < Base
        attr_reader :name
        attr_reader :receiver
        attr_reader :args

        def initialize(receiver:, name:, args: Argument::AnySeq.new)
          @name = name
          @receiver = receiver
          @args = args
        end

        def test_node(node)
          case node&.type
          when :send, :csend
            return false unless name == node.children[1]
            return false unless receiver.test_node(node.children[0])
            return false unless test_args(node.children.drop(2), args)
            true
          end
        end

        def test_args(nodes, args)
          if !args || nodes.empty?
            return nodes.empty? && !args
          end

          case args
          when Argument::AnySeq
            true
          when Argument::Expr
            args.expr =~ nodes.first && test_args(nodes.drop(1), args.tail)
          when Argument::KeyValue
            types = nodes.map(&:type)
            if types == [:hash]
              test_hash_args(nodes.first, args)
            elsif types == [:hash, :kwsplat]
              true
            else
              false
            end
          end
        end

        def test_hash_args(node, args)
          hash = node.children.each.with_object({}) do |pair, h|
            key = pair.children[0]
            value = pair.children[1]

            if key.type == :sym
              h[key.children[0]] = value
            end
          end

          while args
            if args.is_a?(Argument::KeyValue)
              node = hash[args.key]

              if !args.negated == (node && args.value.test_node(node))
                hash.delete args.key
              else
                return false
              end
            else
              break
            end

            args = args.tail
          end

          args.is_a?(Argument::AnySeq) || hash.empty?
        end
      end
    end
  end
end
