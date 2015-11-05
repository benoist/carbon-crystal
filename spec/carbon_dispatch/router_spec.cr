require "../spec_helper"

module CarbonDispatchTest
  class BlogPostsController < CarbonController::Base
    def index
    end

    def show
    end

    def new
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end
  end

  class TestController < CarbonController::Base
    def index
    end

    def new
    end

    def create
    end

    def update
    end

    def destroy
    end
  end

  class Router < CarbonDispatch::Router
    get "/", controller: "test", action: "index"
    get "/new", controller: "test", action: "new"
    post "/", controller: "test", action: "create"
    put "/:id", controller: "test", action: "update"
    patch "/:id", controller: "test", action: "update"
    delete "/:id", controller: "test", action: "destroy"

    resources :blog_posts

    resources :test, only: [:index]
    resources :blog_posts, except: [:new, :create, :show, :edit, :update, :destroy]
  end

  describe CarbonDispatch::Router do
    it "creates routes" do
      router = Router.routes
      router.should be_a(Array(CarbonDispatch::Route))
    end

    it "adds routes" do
      routes = Router.routes
      routes[0].should eq CarbonDispatch::Route.create("test", "index", ["GET"], "/")
      routes[1].should eq CarbonDispatch::Route.create("test", "new", ["GET"], "/new")
      routes[2].should eq CarbonDispatch::Route.create("test", "create", ["POST"], "/")
      routes[3].should eq CarbonDispatch::Route.create("test", "update", ["PUT"], "/:id")
      routes[4].should eq CarbonDispatch::Route.create("test", "update", ["PATCH"], "/:id")
      routes[5].should eq CarbonDispatch::Route.create("test", "destroy", ["DELETE"], "/:id")
    end

    it "adds resources" do
      routes = Router.routes
      routes[6].should eq CarbonDispatch::Route.create("blog_posts", "index", ["GET"], "/blog_posts")
      routes[7].should eq CarbonDispatch::Route.create("blog_posts", "new", ["GET"], "/blog_posts/new")
      routes[8].should eq CarbonDispatch::Route.create("blog_posts", "create", ["POST"], "/blog_posts")
      routes[9].should eq CarbonDispatch::Route.create("blog_posts", "show", ["GET"], "/blog_posts/:id")
      routes[10].should eq CarbonDispatch::Route.create("blog_posts", "edit", ["GET"], "/blog_posts/:id/edit")
      routes[11].should eq CarbonDispatch::Route.create("blog_posts", "update", ["PATCH", "PUT"], "/blog_posts/:id")
      routes[12].should eq CarbonDispatch::Route.create("blog_posts", "destroy", ["DELETE"], "/blog_posts/:id")
    end

    it "adds resources with only" do
      routes = Router.routes
      routes[13].should eq CarbonDispatch::Route.create("test", "index", ["GET"], "/test")
    end

    it "adds resources with except" do
      routes = Router.routes
      routes[14].should eq CarbonDispatch::Route.create("blog_posts", "index", ["GET"], "/blog_posts")
      routes.size.should eq 15
    end
  end
end
