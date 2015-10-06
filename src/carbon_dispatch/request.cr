class CarbonDispatch::Request
  getter :request

  delegate :path, @request
  delegate :method, @request
  delegate :headers, @request

  def initialize(@request)
  end

  def ip
    "127.0.0.1"
  end
end
