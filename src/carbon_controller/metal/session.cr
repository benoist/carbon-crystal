module CarbonController # :nodoc:
  module Session
    def process_action(name, block)
      super
      @_request.session.set_cookie
    end

    def session
      @_request.session.not_nil!
    end

    def reset_session
      session.destroy
    end
  end
end
