class CarbonDispatch::Response
  property :status
  property :headers
  property :body

  def initialize
    @status = 200
    @headers = HTTP::Headers.new
    @body = BodyProxy.new(nil)
    @callbacks = [] of ->
  end

  def to_http_response
    @callbacks.map { |callback| callback.call }
    HTTP::Response.new(status, body.to_s, headers)
  end

  def register_callback(&block)
    @callbacks << block
  end

  def body=(body : String)
    @body = BodyProxy.new(body)
  end
end
