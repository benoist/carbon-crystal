module CarbonSupport::Callbacks
end

require "./callbacks/environment"
require "./callbacks/chain"
require "./callbacks/callback"
require "./callbacks/sequence"

module CarbonSupport::Callbacks
  module DescendantMethods
    macro included
      def load_callbacks
        super
      end
    end
  end

  macro included
    macro inherited
      include DescendantMethods
    end

    def load_callbacks
      @callbacks ||= Hash(String, CallbackChain).new
    end
  end

  macro define_callbacks(name, options = CallbackChain::Options.new)
    def load_callbacks
      previous_def.tap do |callbacks|
        callbacks["{{name.id}}"] = CallbackChain.new("{{name.id}}", {{options.id}})
      end
    end
  end

  macro set_callback(name, type, filter, options = Callback::Options.new)
    def load_callbacks
      previous_def.tap do |callbacks|
        chain = callbacks["{{name.id}}"]
        {% if type == :around %}
          around = ->(block : -> ) { !!{{filter.id}}(&block) }
          callback = Callback::Around.new("{{filter.id}}", around, {{options.id}}, chain.options)
        {% elsif type == :before %}
          before = ->(block : ->) { !!{{filter.id}} }
          callback = Callback::Before.new("{{filter.id}}", before, {{options.id}}, chain.options)
        {% elsif type == :after %}
          after = ->(block : ->) { !!{{filter.id}} }
          callback = Callback::After.new("{{filter.id}}", after, {{options.id}}, chain.options)
        {% end %}
        chain.append(callback)
      end
    end
  end

  def run_callbacks(name, &block : -> Object)
    chain = load_callbacks[name.to_s]
    runner = chain.compile
    e = Environment.new(self, false, nil, &block)
    runner.call(e)
    e.value
  end
end
