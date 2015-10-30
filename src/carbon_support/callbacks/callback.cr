module CarbonSupport::Callbacks
  abstract class Callback
    class Options
    end

    getter :name, :kind, :block

    def duplicates?(other)
      false
    end

    class Before < Callback
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options)
        @kind = :before
      end

      def apply(sequence)
        sequence.before(self)
      end

      def call(env : Environment)
        if !env.halted
          result = @block.call ->{}
          env.halted = result == false
          env.value
          if env.halted
            puts "halted"
          end
        end
        env
      end
    end

    class After < Callback
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options)
        @kind = :after
      end

      def call(env : Environment)
        if !env.halted || !@chain_options.skip_after_callbacks_if_terminated
          result = @block.call ->{}
          env.halted = result == false
          env.value
          if env.halted
            puts "halted"
          end
        end
        env
      end

      def apply(sequence)
        sequence.after(self)
      end
    end

    class Around < Callback
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options)
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
