# Load the Carbon application.
require "./application"

Carbon.root = File.expand_path("../", File.dirname(__FILE__))
CarbonView.load_views "src/views", "../../src/carbon_view/process"

require "../src/**"

require "./routes"

# Initialize the Carbon application.
Carbon.application.initialize!
