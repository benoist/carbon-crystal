require "spec"
require "../src/all"
require "./support/*"

File.write("test.log", "clear")
Carbon.logger = Logger.new(File.open("test.log", "w")).tap do |logger|
  logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
    io << message
  end
  logger.level = Carbon.env.development? ? Logger::DEBUG : Logger::INFO
end
