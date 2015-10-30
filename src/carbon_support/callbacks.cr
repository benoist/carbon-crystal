require "./callbacks/environment"
require "./callbacks/chain"
require "./callbacks/callback"
require "./callbacks/sequence"

module CarbonSupport::Callbacks
  macro define_callbacks(*args)
    {% options = !args.last.is_a?(SymbolLiteral) ? args.last : "CallbackChain::Options.new" %}
    {% names = args.select { |arg| arg.is_a?(SymbolLiteral) } %}

    {% for name in names %}
      private def load_{{name.id}}_callbacks
        @_{{name.id}}_callbacks = CallbackChain.new("{{name.id}}", {{options.id}})
      end
    {% end %}
  end

  macro set_callback(name, type, filter, options = Callback::Options.new)
    private def load_{{name.id}}_callbacks
      previous_def.tap do |chain|
        {% if type == :around %}
          around = ->(block : ->) { {{filter.id}}(&block) }
          callback = Callback::Around.new("{{name.id}}", around, {{options.id}}, chain.options)
        {% elsif type == :before %}
          before = ->(block : ->) { {{filter.id}} }
          callback = Callback::Before.new("{{name.id}}", before, {{options.id}}, chain.options)
        {% elsif type == :after %}
          after = ->(block : ->) { {{filter.id}} }
          callback = Callback::After.new("{{name.id}}", after, {{options.id}}, chain.options)
        {% end %}
        chain.append(callback)
      end
    end
  end

  macro run_callbacks(for, &block)
    callbacks = load_{{for.id}}_callbacks

    runner = callbacks.compile
    e = CarbonSupport::Callbacks::Environment.new(self, false, nil) {{ block.id }}
    runner.call(e)
    e.value
  end
end
