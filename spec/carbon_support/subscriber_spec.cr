require "../spec_helper"

module CarbonSupportTest
  include CarbonSupport::Notifications

  class TestSubscriber < CarbonSupport::Subscriber

    def self.events
      @@events ||= [] of Event
    end

    def self.clear
      @@events = [] of Event
    end

    def open_party(event)
      events << event
    end

    private def private_party(event)
      events << event
    end

    attach_to :doodle
  end

  describe CarbonSupport::Subscriber do

    it "attaches subscribers" do
      TestSubscriber.clear
      CarbonSupport::Notifications.instrument("open_party.doodle")
      TestSubscriber.events.first.name.should eq "open_party.doodle"
    end

    it "attaches only one subscribers" do
      TestSubscriber.clear
      CarbonSupport::Notifications.instrument("open_party.doodle")
      TestSubscriber.events.size.should eq 1
    end

    it "does not attach private methdos" do
      TestSubscriber.clear
      CarbonSupport::Notifications.instrument("open_party.doodle")
      CarbonSupport::Notifications.instrument("private_party.doodle")

      TestSubscriber.events.empty?.should be_truthy
    end
  end
end
