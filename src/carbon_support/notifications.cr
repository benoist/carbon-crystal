require "./notifications/payload"
require "./notifications/fanout"
require "./notifications/event"
require "./notifications/instrumenter"
require "./subscriber"

module CarbonSupport
  module Notifications

    def self.notifier
      @@notifier ||= Fanout.new
    end

    def self.publish(name, *args)
      notifier.publish(name, *args)
    end

    def self.instrument(name, payload = Payload.new)
      if notifier.listening?(name)
        instrumenter.instrument(name, payload) { yield payload if block_given? }
      else
        yield payload if block_given?
      end
    end

    def self.instrument(name, payload = Payload.new)
      if notifier.listening?(name)
        instrumenter.instrument(name, payload) {}
      end
    end

    def self.subscribe(*args)
      notifier.subscribe(*args)
    end

    def self.subscribe(*args, &block)
      notifier.subscribe(*args, block)
    end

    def self.subscribed(callback, *args, &block)
      subscriber = subscribe(*args, &callback)
      yield
    ensure
      unsubscribe(subscriber)
    end

    def self.unsubscribe(subscriber_or_name)
      notifier.unsubscribe(subscriber_or_name)
    end

    def self.instrumenter
      InstrumentationRegistry::INSTANCE.instrumenter_for(notifier)
    end

    class InstrumentationRegistry # :nodoc:
      INSTANCE = new
      def initialize
        @registry = Hash(Fanout, Instrumenter).new
      end

      def instrumenter_for(notifier)
        @registry[notifier] ||= Instrumenter.new(notifier)
      end
    end
  end
end
