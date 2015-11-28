module CarbonController # :nodoc:
  module Flash
    private def flash
      request.flash
    end
  end
end
