module CarbonSupport::Callbacks
  abstract class Callback(T)
    class Options
    end

    getter :name, :kind, :block

    def duplicates?(other)
      false
    end

    class Before(T) < Callback(T)
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options(T))
        @kind = :before
      end

      def apply(sequence)
        sequence.before(self)
      end

      def call(env : Environment(T))
        halted_lambda = @chain_options.terminator
        target = env.target

        if !env.halted
          result = @block.call ->{}
          env.halted = halted_lambda.call(env.target, result) if halted_lambda
          target.halted_callback_hook(@name) if env.halted && target.responds_to?(:halted_callback_hook)
        end
        env
      end
    end

    class After(T) < Callback(T)
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options(T))
        @kind = :after
      end

      def call(env : Environment(T))
        if !env.halted || !@chain_options.skip_after_callbacks_if_terminated
          result = @block.call ->{}
          env.halted = result == false
        end
        env
      end

      def apply(sequence)
        sequence.after(self)
      end
    end

    class Around(T) < Callback(T)
      def initialize(@name, @block, @callback_options : Callback::Options, @chain_options : CallbackChain::Options(T))
        @kind = :after
      end

      def apply(sequence)
        sequence.around(self)
      end

      def call(env : Environment(T), block : ->)
        if !env.halted
          @block.call(block)
        end
        env
      end
    end
  end
end
