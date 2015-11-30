module CarbonView
  macro load_views(view_dir, processor = "carbon_view/process")
    \{{run({{processor}}, {{ view_dir }}) }}
  end

  class Base
    @@views = [] of Base.class

    def self.views
      @@views
    end

    def initialize(@controller)
    end

    macro method_missing(name)
      @controller.@{{name.id}}
    end
  end
end

require "./view"
require "./layout"
require "./partial"
