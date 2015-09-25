class ExampleApp::Router < CarbonDispatch::Router
  get "new", "application#new"
  get "", "application#index"
end

Carbon.application.router = ExampleApp::Router.new

