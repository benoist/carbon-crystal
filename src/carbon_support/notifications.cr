require "./notifications/payload"
require "./notifications/fanout"
require "./notifications/event"
require "./notifications/instrumenter"
require "./subscriber"

module CarbonSupport
  module Notifications

    def self.notifier=(notifier)
      @@notifier = notifier
    end

    def self.notifier
      @@notifier ||= Fanout.new
    end

    def self.publish(name, started, finish, id, payload)
      notifier.publish(name, started, finish, id, payload)
    end

    def self.instrument(name, payload = Payload.new)
      if notifier.listening?(name)
        instrumenter.instrument(name, payload) { yield payload }
      else
        yield payload
      end
    end

    def self.instrument(name, payload = Payload.new)
      if notifier.listening?(name)
        instrumenter.instrument(name, payload) {}
      end
    end

    def self.subscribe(pattern, subscriber : Subscriber)
      notifier.subscribe(pattern, subscriber)
    end

    def self.subscribe(pattern, callback : CarbonSupport::Notifications::Event -> )
      notifier.subscribe(pattern, callback)
    end

    def self.subscribe(pattern, &block)
      notifier.subscribe(pattern, block)
    end

    def self.subscribed(callback, name, &block)
      subscriber = subscribe(name, callback)
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
