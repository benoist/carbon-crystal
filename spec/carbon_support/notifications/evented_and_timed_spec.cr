require "../../spec_helper"

module CarbonSupportTest
  include CarbonSupport::Notifications

  class Listener < CarbonSupport::Subscriber
    getter :events

    def initialize
      @events = [] of Array(Symbol | String | Time | Int32 | CarbonSupport::Notifications::Payload)
    end

    def start(name, id, payload)
      @events << [:start, name, id, payload]
    end

    def finish(name, id, payload)
      @events << [:finish, name, id, payload]
    end

    def call(name, start, finish, id, payload)
      @events << [:call, name, start, finish, id, payload]
    end
  end

  class ListenerWithTimedSupport < Listener
    def call(name, start, finish, id, payload)
      @events << [:call, name, start, finish, id, payload]
    end
  end

  it "listens for evented events" do
    notifier = Fanout.new
    listener = Listener.new
    notifier.subscribe "hi", listener
    notifier.start  "hi", 1, Payload.new
    notifier.start  "hi", 2, Payload.new
    notifier.finish "hi", 2, Payload.new
    notifier.finish "hi", 1, Payload.new

    listener.events.size.should eq(4)
    listener.events.should eq [
      [:start, "hi", 1, Payload.new],
      [:start, "hi", 2, Payload.new],
      [:finish, "hi", 2, Payload.new],
      [:finish, "hi", 1, Payload.new],
    ]
  end

  it "handles no events" do
    notifier = Fanout.new
    listener = Listener.new
    notifier.subscribe "hi", listener
    notifier.start "world", 1, Payload.new
    listener.events.size.should eq 0
  end

  it "handles priority" do
    notifier = Fanout.new
    listener = ListenerWithTimedSupport.new
    notifier.subscribe "hi", listener

    notifier.start "hi", 1, Payload.new
    notifier.finish "hi", 1, Payload.new

    listener.events.should eq [
                                  [:start, "hi", 1, Payload.new],
                                  [:finish, "hi", 1, Payload.new]
                              ]
  end
end
