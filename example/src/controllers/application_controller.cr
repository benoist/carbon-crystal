class ApplicationController < CarbonController::Base
  before_action :before
  after_action :after2

  def index
    @test = "test"

    render_template "index"
  end

  def new
    render_json ["new"]
  end

  private def before
    Carbon.logger.debug "Before action"
  end

  private def after2
    Carbon.logger.debug "After action"
  end
end
