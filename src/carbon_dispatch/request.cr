require "./request/session"

class CarbonDispatch::Request
  getter :request, :path_params

  delegate :path, @request
  delegate :method, @request
  delegate :headers, @request
  delegate :body, @request

  def initialize(@request : HTTP::Request)
    @path_params = Hash(String, String?).new
  end

  def ssl?
    scheme == "https"
  end

  def protocol
    @protocol ||= ssl? ? "https://" : "http://"
  end

  def scheme(default = true)
    if headers["HTTPS"]? == "on"
      "https"
    elsif headers["HTTP_X_FORWARDED_SSL"]? == "on"
      "https"
    elsif headers["HTTP_X_FORWARDED_SCHEME"]?
      headers["HTTP_X_FORWARDED_SCHEME"]?
    elsif headers["HTTP_X_FORWARDED_PROTO"]?
      forwarded_protocol = headers["HTTP_X_FORWARDED_PROTO"]?
      forwarded_protocol.to_s.split(",").first
    else
      "http" if default
    end
  end

  def port
    port_from_host = raw_host_with_port.to_s.match(/:(\d+)$/) { |md| md[1]? }

    port = begin
      if scheme(false)
        standard_port
      elsif port_from_host
        port_from_host
      elsif headers["HTTP_X_FORWARDED_PORT"]?
        headers["HTTP_X_FORWARDED_PORT"]?
      elsif headers["SERVER_PORT"]?
        headers["SERVER_PORT"]?
      else
        standard_port
      end
    end

    port.to_i if port
  end

  STANDARD_PORTS_FOR_SCHEME = {"http": 80, "https": 443}

  def standard_port
    STANDARD_PORTS_FOR_SCHEME[scheme]? || 80
  end

  def standard_port?
    STANDARD_PORTS_FOR_SCHEME.values.includes?(port)
  end

  def host_with_port
    if standard_port?
      host
    else
      "#{host}:#{port}"
    end
  end

  def host
    raw_host_with_port.sub(/:\d+$/, "")
  end

  def raw_host_with_port
    forwarded_host = headers["HTTP_X_FORWARDED_HOST"]?

    if forwarded_host
      forwarded_host.to_s.split(/,\s?/).last
    else
      server_name_or_addr = headers["SERVER_NAME"]? || headers["SERVER_ADDR"]?

      headers["HOST"]? || headers["HTTP_HOST"]? || "#{server_name_or_addr}:#{headers["SERVER_PORT"]?}"
    end
  end

  def params
    @params ||= request_params.merge(path_params.merge(query_params))
  end

  def query_params
    query_params = @query_params
    return query_params if query_params

    query_params = Hash(String, String?).new

    HTTP::Params.parse(@request.query.to_s) do |key, value|
      query_params[key] = value
    end
    @query_params = query_params
  end

  def request_params
    request_params = @request_params
    return request_params if request_params

    request_params = Hash(String, String?).new

    HTTP::Params.parse(@request.body.to_s) do |key, value|
      request_params[key] = value
    end
    @request_params = request_params
  end

  def path_params=(params : Hash(String, String?))
    @path_params = params
  end

  def ip
    remote_addrs = split_ip_addresses(headers["REMOTE_ADDR"]?)
    remote_addrs = reject_trusted_ip_addresses(remote_addrs)

    return remote_addrs.first if !remote_addrs.empty?

    forwarded_ips = split_ip_addresses(headers["HTTP_X_FORWARDED_FOR"]?)
    forwarded_ips = reject_trusted_ip_addresses(forwarded_ips)

    forwarded_ips.last?
  end

  def trusted_proxy?(ip)
    ip =~ /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
  end

  private def split_ip_addresses(ip_addresses)
    if ip_addresses
      ip_addresses.strip.split(/[,\s]+/)
    else
      [] of String
    end
  end

  private def reject_trusted_ip_addresses(ip_addresses)
    ip_addresses.reject { |ip| trusted_proxy?(ip) }
  end

  private def uri
    (@uri ||= URI.parse(@request.resource)).not_nil!
  end
end
