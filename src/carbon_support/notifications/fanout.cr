module CarbonSupport
  module Notifications
    class Fanout
      def initialize
        @subscribers = [] of (Subscribers::Evented | Subscribers::Timed)
        @listeners_for = {} of String => Array(Subscribers::Evented | Subscribers::Timed)
        super
      end

      def subscribe(pattern = nil, block = Proc.new)
        subscriber = Subscribers.new pattern, block
        @subscribers << subscriber
        @listeners_for.clear
        subscriber
      end

      def unsubscribe(subscriber_or_name)
        case subscriber_or_name
        when String
          @subscribers.reject! { |s| s.matches?(subscriber_or_name) }
        else
          @subscribers.delete(subscriber_or_name)
        end

        @listeners_for.clear
      end

      def start(name, id, payload)
        listeners_for(name).each { |s| s.start(name, id, payload) }
      end

      def finish(name, id, payload)
        listeners_for(name).each { |s| s.finish(name, id, payload) }
      end

      def publish(name, *args)
        listeners_for(name).each { |s| s.publish(name, *args) }
      end

      def listeners_for(name)
        @listeners_for[name] ||= @subscribers.select { |s| s.subscribed_to?(name) }
      end

      def listening?(name)
        listeners_for(name).any?
      end

      # This is a sync queue, so there is no waiting.
      def wait
      end

      module Subscribers # :nodoc:
        def self.new(pattern, listener)
          if listener.responds_to?(:start) && listener.responds_to?(:finish)
            Evented.new pattern, listener
          elsif listener.responds_to?(:call)
            Timed.new pattern, listener
          else
            raise "Invalid listener"
          end
        end

        class Evented #:nodoc:
          def self.timestack
            @@timestack ||= Hash(Fiber, Array(Time)).new { |h,k| h[k] = [] of Time }
          end

          def initialize(pattern, delegate)
            @pattern = pattern
            @delegate = delegate
            @can_publish = delegate.responds_to?(:publish)
          end

          def publish(name, *args)
            if @can_publish
              @delegate.publish name, *args
            end
          end

          def start(name, id, payload)
            @delegate.start name, id, payload
          end

          def finish(name, id, payload)
            @delegate.finish name, id, payload
          end

          def subscribed_to?(name)
            @pattern === name
          end

          def matches?(name)
            @pattern && @pattern === name
          end
        end

        class Timed < Evented
          def publish(name, *args)
            @delegate.call name, *args
          end

          def start(name, id, payload)
            self.class.timestack[Fiber.current].push Time.now
          end

          def finish(name, id, payload)
            started = self.class.timestack[Fiber.current].pop
            @delegate.call(name, started, Time.now, id, payload)
          end
        end
      end
    end
  end
end
