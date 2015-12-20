module CarbonView
  class Layout < View
    def render(view)
      String.build do |io|
        to_s io do
          view.render
        end
      end
    end
  end
end
