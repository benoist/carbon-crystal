module CarbonSupport::Callbacks
  class Callback
    getter :method
    getter :only
    getter :except
    getter :block
    getter :time

    def initialize(@method, @time, only, except, @block)
      @only = only || [] of Symbol
      @except = except || [] of Symbol

      raise ArgumentError.new("Cannot both set only and except for callback #{@method}") if @only.any? && @except.any?
    end

    def run_callback(method)
      if only.any?
        return block.call if only.includes?(method)
      elsif except.any?
        return block.call unless except.includes?(method)
      else
        block.call
      end
    end

    def before?
      time == :before
    end

    def after?
      time == :after
    end
  end

  macro included
    macro inherited
      private def load_callbacks
        super
      end

      private def load_skip_callbacks
        super
      end
    end
  end

  macro skip_before_action(method)
    private def load_skip_callbacks
      previous_def << {{method}}
    end
  end

  macro before_action(method, only = nil, except = nil)
    private def load_callbacks
      callbacks = previous_def
      callbacks << CarbonSupport::Callbacks::Callback.new({{method}}, :before, {{only}}, {{except}}, ->() { {{method.id}} })
      callbacks
    end
  end

  macro after_action(method, only = nil, except = nil)
  private def load_callbacks
      callbacks = previous_def
      callbacks << CarbonSupport::Callbacks::Callback.new({{method}}, :after, {{only}}, {{except}}, ->() { {{method.id}} })
      callbacks
    end
  end

  private def callbacks
    @callbacks ||= load_callbacks
  end

  private def skip_callbacks
    @skip_callbacks ||= load_skip_callbacks
  end

  private def load_callbacks
    [] of CarbonSupport::Callbacks::Callback
  end

  private def load_skip_callbacks
    [] of Symbol
  end

  def run_callbacks(method : Symbol)
    halted = !callbacks.select(&.before?).all? do |before|
      if !skip_callbacks.includes?(before.method)
        before.run_callback(method) != false
      else
        true
      end
    end
    return false if halted

    yield

    callbacks.select(&.after?).all? do |after|
      if !skip_callbacks.includes?(after.method)
        after.run_callback(method) != false
      else
        true
      end
    end
  end
end
