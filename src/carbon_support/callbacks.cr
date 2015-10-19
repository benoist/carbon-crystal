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
    end

    def run_callback(method)
      block.call if only.includes?(method) || !except.includes?(method)
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
      private def callbacks
        super
      end

      private def skip_callbacks
        super
      end
    end
  end

  macro skip_before_action(method)
    private def skip_callbacks
      previous_def << {{method}}
    end
  end

  macro before_action(method, only = nil, except = nil)
    private def callbacks
      callbacks = previous_def
      callbacks << CarbonSupport::Callbacks::Callback.new({{method}}, :before, {{only}}, {{except}}, ->() { {{method.id}} })
      callbacks
    end
  end

  macro after_action(method, only = nil, except = nil)
    private def callbacks
      callbacks = previous_def
      callbacks << CarbonSupport::Callbacks::Callback.new({{method}}, :after, {{only}}, {{except}}, ->() { {{method.id}} })
      callbacks
    end
  end

  private def callbacks
    @callbacks ||= [] of CarbonSupport::Callbacks::Callback
  end

  private def skip_callbacks
    @skip_callbacks ||= [] of Symbol
  end

  def run_callbacks(method : Symbol)
    callbacks.select(&.before?).each do |before|
      before.run_callback(method) if !skip_callbacks.includes?(before.method)
    end

    yield

    callbacks.select(&.after?).each do |after|
      after.run_callback(method) if !skip_callbacks.includes?(after.method)
    end
  end
end
