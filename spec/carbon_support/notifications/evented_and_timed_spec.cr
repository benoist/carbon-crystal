require "../../spec_helper"

module CarbonSupportTest
  include CarbonSupport::Notifications

  class Listener < CarbonSupport::Subscriber
    getter :events

    def initialize
      @events = [] of Event
    end

    def start(name, id, payload)
      @events << Event.new("start.#{name}", Time.epoch(0), Time.epoch(0), id, payload)
    end

    def finish(name, id, payload)
      @events << Event.new("finish.#{name}", Time.epoch(0), Time.epoch(0), id, payload)
    end

    def call(name, start, finish, id, payload)
      @events << Event.new("call.#{name}", start, finish, id, payload)
    end
  end

  class ListenerWithTimedSupport < Listener
    def call(name, start, finish, id, payload)
      @events << Event.new("call.#{name}", start, finish, id, payload)
    end
  end

  it "listens for evented events" do
    notifier = Fanout.new
    listener = Listener.new
    notifier.subscribe "hi", listener
    notifier.start "hi", "1", Payload.new
    notifier.start "hi", "2", Payload.new
    notifier.finish "hi", "2", Payload.new
    notifier.finish "hi", "1", Payload.new

    listener.events.size.should eq(4)
    listener.events.should eq [
      Event.new("start.hi", Time.epoch(0), Time.epoch(0), "1", Payload.new),
      Event.new("start.hi", Time.epoch(0), Time.epoch(0), "2", Payload.new),
      Event.new("finish.hi", Time.epoch(0), Time.epoch(0), "2", Payload.new),
      Event.new("finish.hi", Time.epoch(0), Time.epoch(0), "1", Payload.new),
    ]
  end

  it "handles no events" do
    notifier = Fanout.new
    listener = Listener.new
    notifier.subscribe "hi", listener
    notifier.start "world", "1", Payload.new
    listener.events.size.should eq 0
  end

  it "handles priority" do
    notifier = Fanout.new
    listener = ListenerWithTimedSupport.new
    notifier.subscribe "hi", listener

    notifier.start "hi", "1", Payload.new
    notifier.finish "hi", "1", Payload.new

    listener.events.should eq [
      Event.new("start.hi", Time.epoch(0), Time.epoch(0), "1", Payload.new),
      Event.new("finish.hi", Time.epoch(0), Time.epoch(0), "1", Payload.new),
    ]
  end
end
