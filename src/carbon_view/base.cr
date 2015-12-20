module CarbonView
  class Base
  end
end

require "./buffers"
require "./helpers"
require "./context"
require "./view"
require "./layout"
require "./partial"

module CarbonView
  macro load_views(view_dir, processor = "carbon_view/process")
    \{{run({{processor}}, {{ view_dir }}) }}
  end

  class Base
    include Context
    include Helpers

    @@views = {} of String => View.class
    @@layouts = {} of String => Layout.class

    def self.views
      @@views
    end

    def self.layouts
      @@layouts
    end

    def initialize(@controller = nil)
    end

    macro method_missing(name)
      {% if name.is_a?(StringLiteral) %}
        controller = @controller
        controller.try(&.{{name.id}}) if controller.responds_to?(:{{name.id}})
      {% end %}
    end
  end
end
