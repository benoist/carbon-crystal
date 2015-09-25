module CarbonView
  class Base
    def initialize(@controller)
    end

    macro method_missing(name)
      @controller.@{{name.id}}
    end
  end
end
