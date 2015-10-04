class ApplicationController < CarbonController::Base
  def index
    @test = "test"

    render_template "index"
  end

  def new
    render_json ["new"]
  end
end
