class CarbonDispatch::Response
  property :status
  property :headers
  property :body

  def initialize
    @status = 200
    @headers = HTTP::Headers.new
    @body = nil
    @callbacks = [] of ->
  end

  def to_http_response
    @callbacks.map { |callback| callback.call }
    HTTP::Response.new(status, body, headers)
  end

  def register_callback(&block)
    @callbacks << block
  end
end
