require "../spec_helper"

module CarbonSupportTest
  class MyLogSubscriber < CarbonSupport::LogSubscriber
    getter :event

    def some_event(event)
      @event = event
      info event.name
    end

    def foo(event)
      debug "debug"
      info { "info" }
      warn "warn"
    end

    def bar(event)
      info "#{color("cool", :red)}, #{color("isn't it?", :blue, true)}"
    end

    def puke(event)
      raise "puke"
    end
  end

  describe CarbonSupport::LogSubscriber do
    it "logs with colors" do
      IO.pipe do |r, w|
        CarbonSupport::LogSubscriber.logger = Logger.new(w).tap do |logger|
                                                logger.level = Logger::Severity::DEBUG
                                                logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
                                                                     io << message
                                                                   end
                                              end
        log_subscriber = MyLogSubscriber.new
        log_subscriber.bar(nil)

        r.gets.should eq "\e[31mcool\e[0m, \e[1m\e[34misn't it?\e[0m\n"
      end
    end

    it "loggs" do
      IO.pipe do |r, w|
        CarbonSupport::LogSubscriber.logger = Logger.new(w).tap do |logger|
                                                logger.level = Logger::Severity::DEBUG
                                                logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
                                                                     io << message
                                                                   end
                                              end
        log_subscriber = MyLogSubscriber.new
        log_subscriber.foo(nil)

        r.gets.should eq "debug\n"
        r.gets.should eq "info\n"
        r.gets.should eq "warn\n"
      end
    end
  end
end
