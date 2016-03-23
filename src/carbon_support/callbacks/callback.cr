module CarbonSupport::Callbacks
  abstract class Callback
    class Options
    end

    getter :name, :kind, :block

    def duplicates?(other)
      name == other.name && kind == other.kind
    end

    class Before < Callback
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options)
        @kind = :before
      end

      def apply(sequence)
        sequence.before(self)
      end

      def call(env : Environment)
        terminator = @chain_options.terminator
        target = env.target

        if !env.halted
          result = @block.call ->{}
          env.halted = terminator.terminate?(env.target, result)
          target.halted_callback_hook(@name) if env.halted && target.responds_to?(:halted_callback_hook)
        end
        env
      end
    end

    class After < Callback
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options)
        @kind = :after
      end

      def call(env : Environment)
        terminator = @chain_options.terminator
        if !env.halted || !@chain_options.skip_after_callbacks_if_terminated
          result = @block.call ->{}
          env.halted = terminator.terminate?(env.target, result)
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

      def call(env : Environment, block : -> _)
        if !env.halted
          @block.call(block)
        end
        env
      end
    end
  end
end
