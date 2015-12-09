Carbon.application.routes.draw do
  # TODO: Use the RedirectionsController, once the segmentation fault is fixed.
  # get "/redirect_to_new", controller: "redirections", action: "to_new"
  # get "/redirect_to_google", controller: "redirections", action: "to_google"
  get "/redirect_to_new", controller: "application", action: "redirect_to_new"
  get "/redirect_to_google", controller: "application", action: "redirect_to_google"

  get "/new", controller: "application", action: "new"
  get "/", controller: "application", action: "index"
end
