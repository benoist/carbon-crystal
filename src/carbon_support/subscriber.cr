# require "../carbon_support/notifications/event"

# module CarbonSupport
#   class Subscriber
#     def initialize
#       @timestack = Hash(Fiber, Array(Time)).new { |h,k| h[k] = [] of Time }
#     end
#
#     def initialize(&@block : CarbonSupport::Notifications::Event -> Void)
#       @timestack = Hash(Fiber, Array(Time)).new { |h,k| h[k] = [] of Time }
#     end
#
#     def start(event : CarbonSupport::Notifications::Event)
#     end
#
#     def receive_start(event : CarbonSupport::Notifications::Event)
#       @timestack[Fiber.current] << Time.now
#       start(event)
#     end
#
#     def finish(event : CarbonSupport::Notifications::Event)
#     end
#
#     def receive_finish(event : CarbonSupport::Notifications::Event)
#       event.start = @timestack[Fiber.current].pop
#       @timestack.delete(Fiber.current) if @timestack[Fiber.current].size == 0
#       event.finish = Time.now
#
#       finish(event)
#       @block.try &.call(event)
#     end
#   end
# end
# require 'active_support/per_thread_registry'

module CarbonSupport
  class Subscriber
    macro attach_to(namespace, subscriber = new, notifier=CarbonSupport::Notifications)
      @@namespace  = {{namespace}}
      @@subscriber = {{subscriber}}
      @@notifier   = {{notifier}}

      subscribers << @@subscriber

      {% for event in @type.methods %}
        add_event_subscriber({{event.name}})
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

    def self.subscribers
      @@subscribers ||= [] of Subscriber
    end

    macro add_event_subscriber(event)
      unless ["start", "finish"].includes?("{{event}}")
        pattern = "{{event}}.#{@@namespace}"

        # don't add multiple subscribers (eg. if methods are redefined)
        # unless @@subscriber.patterns.includes?(pattern)
          @@subscriber.patterns.try &.:<<(pattern)
          @@notifier.subscribe(pattern, @@subscriber)
        # end
      end
    end

    getter :patterns # :nodoc:

    def initialize
      @queue_key = [self.class.name, object_id].join "-"
      @patterns  = [] of String
    end

    def start(name, id, payload)
      e = CarbonSupport::Notifications::Event.new(name, Time.now, nil, id, payload)
      parent = event_stack.last
      parent << e if parent

      event_stack.push e
    end

    def finish(name, id, payload)
      finished  = Time.now
      event     = event_stack.pop
      event.end = finished
      event.payload = payload

      method = name.split('.').first
      # send(method, event)
    end

    def call(name, started, ended, id, payload)

    end

    private def event_stack
      @event_stack ||= [] of CarbonSupport::Notifications::Event#SubscriberQueueRegistry::INSTANCE.get_queue(@queue_key.to_s)
    end
  end

  # This is a registry for all the event stacks kept for subscribers.
  #
  # See the documentation of <tt>ActiveSupport::PerThreadRegistry</tt>
  # for further details.
  class SubscriberQueueRegistry # :nodoc:
    INSTANCE = new
    def initialize
      @registry = Hash(String, Array(CarbonSupport::Notifications::Event)).new { |h,k| h[k] = [] of CarbonSupport::Notifications::Event }
    end

    def get_queue(queue_key)
      @registry[queue_key]
    end
  end
end
