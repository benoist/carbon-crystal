# require "../spec_helper"
#
# module CarbonSupportTest
#   include CarbonSupport
#   include Notifications
#
#   class TestEvent < Event
#   end
#
#   class TestSubscriber < Subscriber
#     getter :received_event
#     getter :test_event
#
#     def initialize
#       @received_event = Event.new("test", Time.now, nil, 1, Payload.new)
#       @test_event     = Event.new("test", Time.now, nil, 1, Payload.new)
#       super
#     end
#
#     def finish(event)
#       @received_event = event
#     end
#
#     def finish(event : TestEvent)
#       @test_event = event
#     end
#   end
#   subscriber = TestSubscriber.new
#
#   Notifier.instance.subscribe(subscriber)
#
#   describe CarbonSupport::Notifier do
#     it "subscribes only once" do
#       Notifier.instance.subscribe(subscriber)
#       Notifier.instance.subscribe(subscriber)
#       Notifier.instance.subscribers.size.should eq 1
#     end
#
#     it "notifies the subscriber without using a block" do
#       Notifier.instance.instrument(event = Event.new)
#
#       subscriber.received_event.should eq(event)
#     end
#
#     it "notifies the subscriber using an instrumentation block" do
#       Notifier.instance.instrument(event = Event.new) do |payload|
#         event.should eq(payload)
#         sleep 2.milliseconds
#       end
#
#       subscriber.received_event.should eq(event)
#       subscriber.received_event.duration.should be > 1.milliseconds
#     end
#
#     it "notifies the subscriber with nested instrumentations" do
#       Notifier.instance.instrument(outer_event = Event.new) do |payload|
#         Notifier.instance.instrument(inner_event = Event.new)
#         subscriber.received_event.should eq(inner_event)
#       end
#       subscriber.received_event.should eq(outer_event)
#     end
#
#     it "notifies subscribers listening to specific events" do
#       Notifier.instance.instrument(test_event = TestEvent.new)
#
#       subscriber.test_event.should eq test_event
#       subscriber.received_event.should_not eq test_event
#
#       Notifier.instance.instrument(event = Event.new)
#       subscriber.test_event.should_not eq event
#       subscriber.received_event.should eq event
#     end
#   end
# end
