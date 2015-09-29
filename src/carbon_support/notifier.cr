require "./notifications/event"
require "./subscriber"

module CarbonSupport
  class Notifier
    getter subscribers
    INSTANCE = new

    def self.instance
      INSTANCE
    end

    def initialize
      @subscribers = Set(Subscriber).new
    end

    def subscribe(subscriber)
      @subscribers << subscriber
    end

    def unsubscribe(subscriber)
      @subscribers.try &.delete(subscriber)
    end

    def instrument(event)
      instrument(event) {}
    end

    def instrument(event, &block : CarbonSupport::Notifications::Event -> Void)
      @subscribers.try &.each &.receive_start event

      block.call(event)

      @subscribers.try &.each &.receive_finish event
    end
  end
end
