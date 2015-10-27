class CarbonSupport::Callbacks::CallbackChain
  getter :name

  def initialize(name, @options : CallbackOptions)
    @name = name
    @chain = [] of CallbackType
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
