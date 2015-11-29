module CarbonView
  macro load_views(view_dir)
    \{{run("../../src/carbon_view/process", {{ view_dir }}) }}
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
