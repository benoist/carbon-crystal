class CarbonDispatch::Response
  property :status
  property :headers
  property :body
  property :location
  property :content_type

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

  def location=(url : String)
    @location = url
    @headers["Location"] = url
  end

  def content_type=(mime : String)
    @content_type = mime
    @headers["Content-Type"] = mime
  end
end
