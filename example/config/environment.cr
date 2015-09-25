# Load the Rails application.
require "./application"

Carbon.root = File.expand_path("../", File.dirname(__FILE__))

require "./routes"
require "../app/**"

# Initialize the Rails application.
Carbon.application.initialize!
