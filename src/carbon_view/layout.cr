module CarbonView
  class Layout < Base
    def render(view)
      String.build do |io|
        to_s io do
          view.render
        end
      end
    end
  end
end
