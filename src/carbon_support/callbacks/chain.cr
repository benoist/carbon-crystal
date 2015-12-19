class CarbonSupport::Callbacks::CallbackChain
  class Options
    class BoolTerminator
      def terminate?(target, result)
        !result
      end
    end

    getter :terminator, :if, :unless, :skip_after_callbacks_if_terminated

    def initialize(terminator = nil, @if = nil, @unless = nil, @skip_after_callbacks_if_terminated = false)
      if terminator
        @terminator = terminator
      else
        @terminator = BoolTerminator.new
      end
    end
  end

  getter :name, :options

  def initialize(@name, @options = Options.new)
    @chain = [] of Callback
  end

  def append(callback : Callback)
    @chain.push(callback)
  end

  def compile
    final_sequence = CallbackSequence.new ->(environment : Environment) do
      block = environment.run_block
      environment.value = !environment.halted && (!block || block.call)
      environment
    end
    @callbacks ||= @chain.reverse.inject(final_sequence) do |callback_sequence, callback|
      callback.apply callback_sequence
    end
  end

  def append(*callbacks)
    callbacks.each { |c| append_one(c) }
  end

  def prepend(*callbacks)
    callbacks.each { |c| prepend_one(c) }
  end

  private def append_one(callback)
    @callbacks = nil
    remove_duplicates(callback)
    @chain.push(callback)
  end

  private def prepend_one(callback)
    @callbacks = nil
    remove_duplicates(callback)
    @chain.unshift(callback)
  end

  private def remove_duplicates(callback)
    @callbacks = nil
    @chain.reject! { |c| callback.duplicates?(c) }
  end
end
