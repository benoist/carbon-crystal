module CarbonSupport::Callbacks(T)
end

require "./callbacks/environment"
require "./callbacks/chain"
require "./callbacks/callback"
require "./callbacks/sequence"

module CarbonSupport::Callbacks(T)
  macro define_callbacks(*args)
    def halted_callback_hook
    end

    {% options = !args.last.is_a?(SymbolLiteral) ? args.last : "CallbackChain::Options(T).new" %}
    {% names = args.select { |arg| arg.is_a?(SymbolLiteral) } %}

    {% for name in names %}
      private def load_{{name.id}}_callbacks
        @_{{name.id}}_callbacks = CallbackChain(T).new("{{name.id}}", {{options.id}})
      end
    {% end %}
  end

  macro set_callback(name, type, filter, options = Callback::Options.new)
    private def load_{{name.id}}_callbacks
      previous_def.tap do |chain|
        {% if type == :around %}
          around = ->(block : -> ) { !!{{filter.id}}(&block) }
          callback = Callback::Around(T).new("{{name.id}}", around, {{options.id}}, chain.options)
        {% elsif type == :before %}
          before = ->(block : ->) { !!{{filter.id}} }
          callback = Callback::Before(T).new("{{name.id}}", before, {{options.id}}, chain.options)
        {% elsif type == :after %}
          after = ->(block : ->) { !!{{filter.id}} }
          callback = Callback::After(T).new("{{name.id}}", after, {{options.id}}, chain.options)
        {% end %}
        chain.append(callback)
      end
    end
  end

  macro run_callbacks(for, &block)
    callbacks = load_{{for.id}}_callbacks

    runner = callbacks.compile
    e = CarbonSupport::Callbacks::Environment(T).new(self, false, nil) {{ block.id }}
    runner.call(e)
    e.value
  end
end
