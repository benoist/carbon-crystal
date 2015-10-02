class Router < CarbonDispatch::Router
  get "/new", controller: "application", action: "new"
  get "/", controller: "application", action: "index"
end

