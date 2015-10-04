module CarbonView
  class Base
    @@views = {} of String => Base.class

    def self.views
      @@views
    end

    def self.[](template)
      @@views[template]
    end

    def self.[]=(template, view)
      @@views[template] = view
    end

    def initialize(@controller)
    end

    macro method_missing(name)
      @controller.@{{name.id}}
    end
  end
end
