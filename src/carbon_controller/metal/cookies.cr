module CarbonController # :nodoc:
  module Cookies
    private def cookies
      request.cookie_jar
    end
  end
end
