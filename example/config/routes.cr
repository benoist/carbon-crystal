Carbon.application.routes.draw do
  get "/new", controller: "application", action: "new"
  get "/", controller: "application", action: "index"
end
