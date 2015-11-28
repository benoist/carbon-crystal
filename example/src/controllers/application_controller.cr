class ApplicationController < CarbonController::Base
  before_action :before
  around_action :around
  after_action :after2

  def index
    @test = session.to_hash.to_json
    session["user_id"] = "1"

    render_template "index"
  end

  def new
    reset_session
    render_json ["new"]
  end

  private def before
    Carbon.logger.debug "Before action"
  end

  private def after2
    Carbon.logger.debug "After action"
  end

  private def around
    Carbon.logger.debug "start"
    yield
    Carbon.logger.debug "finish"
  end
end
