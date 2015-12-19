Carbon.application.routes.draw do
  get "/redirect_to_new", controller: "redirections", action: "to_new"
  get "/redirect_to_google", controller: "redirections", action: "to_google"

  get "/new", controller: "welcome", action: "index"
  get "/", controller: "application", action: "index"
end
