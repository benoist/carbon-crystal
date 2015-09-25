class ApplicationController < CarbonController::Base
  def index
    @test = "test"

    render template: "index"
  end

  def new
    render json: ["new"]
  end
end
