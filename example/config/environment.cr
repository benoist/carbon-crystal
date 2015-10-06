# Load the Carbon application.
require "./application"

Carbon.root = File.expand_path("../", File.dirname(__FILE__))

require "../app/**"

require "./routes"

# Initialize the Carbon application.
Carbon.application.initialize!
