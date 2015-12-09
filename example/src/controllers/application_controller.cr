class ApplicationController < CarbonController::Base
  layout "application"

  before_action :before
  around_action :around
  after_action :after2

  def index
    @test = session.to_hash.to_json

    render_template "index"
  end

  def new
    render_json cookies.cookies
  end

  def redirect_to_new
    redirect_to "/new"
  end

  def redirect_to_google
    redirect_to "http://www.google.com"
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
