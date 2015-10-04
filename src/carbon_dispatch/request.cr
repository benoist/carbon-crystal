class CarbonDispatch::Request
  getter :request

  delegate :path, @request

  def initialize(@request)
  end
end
