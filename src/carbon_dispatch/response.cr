class CarbonDispatch::Response
  property :status
  property :headers
  property :body

  def initialize
    @status = 200
    @headers = HTTP::Headers.new
    @body = nil
  end

  def to_http_response
    HTTP::Response.new(status, body, headers)
  end
end
