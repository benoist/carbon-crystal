module CarbonSupport::Callbacks
  abstract class Callback
    getter :name, :kind, :block

    def duplicates?(other)
      false
    end

    class Before < Callback
      def initialize(@name, @block)
        @kind = :before
      end

      def apply(sequence)
        sequence.before(self)
      end

      def call(env : Environment)
        @block.call ->{}
        env.value
      end
    end

    class After < Callback
      def initialize(@name, @block)
        @kind = :after
      end

      def call(env : Environment)
        @block.call ->{}
        env.value
      end

      def apply(sequence)
        sequence.after(self)
      end
    end

    class Around < Callback
      def initialize(@name, @block)
        @kind = :after
      end

      def apply(sequence)
        sequence.around(self)
      end

      def call(env : Environment, block : ->)
        @block.call(block)
        env.value
      end
    end
  end

  alias CallbackType = (Callback::Around | Callback::Before | Callback::Around)
end
