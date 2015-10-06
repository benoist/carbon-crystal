module CarbonSupport
  class Subscriber
    macro attach_to(namespace, subscriber = {{@type}}.new, notifier=CarbonSupport::Notifications)
      @@namespace  = {{namespace}}
      @@subscriber = {{subscriber}}
      @@notifier   = {{notifier}}

      {% for event in @type.methods %}
        {% if {{event.visibility}} == :public %}
          add_event_subscriber({{event.name}})
        {% end %}
      {% end %}
    end

    # Adds event subscribers for all new methods added to the class.
    def self.method_added(event)
      # Only public methods are added as subscribers, and only if a notifier
      # has been set up. This means that subscribers will only be set up for
      # classes that call #attach_to.
      if public_method_defined?(event) && notifier
        add_event_subscriber(event)
      end
    end

    macro add_event_subscriber(event)
      unless ["start", "finish"].includes?("{{event}}")
        pattern = "{{event}}.#{@@namespace}"

        # don't add multiple subscribers (eg. if methods are redefined)
        unless @@subscriber.patterns.includes?(pattern)
          @@subscriber.patterns << pattern
          @@subscriber.callers[pattern] = ->(e : CarbonSupport::Notifications::Event) { @@subscriber.{{event}}(e) }
          @@notifier.subscribe(pattern, @@subscriber)
        end
      end
    end

    getter :patterns # :nodoc:

    def initialize
      @queue_key = [self.class.name, object_id].join "-"
      @patterns  = [] of String
    end

    def callers
      @callers ||= {} of String => CarbonSupport::Notifications::Event->
    end

    def start(name, id, payload)
      e = CarbonSupport::Notifications::Event.new(name, Time.now, Time.now, id, payload)

      if event_stack.any?
        parent = event_stack.last
        parent << e
      end

      event_stack.push e
    end

    def finish(name, id, payload)
      finished  = Time.now
      event     = event_stack.pop
      event.end = finished
      event.payload = payload

      callers[name].call(event) if callers.has_key?(name)
    end

    def call(event : CarbonSupport::Notifications::Event)
      raise "subscribers cannot respond to all messages"
    end

    private def event_stack
      @event_stack ||= [] of CarbonSupport::Notifications::Event
    end
  end
end
