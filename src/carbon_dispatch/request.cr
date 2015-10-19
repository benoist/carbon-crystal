class CarbonDispatch::Request
  getter :request, :path_params

  delegate :path, @request
  delegate :method, @request
  delegate :headers, @request

  def initialize(@request)
    @path_params = Hash(String, String?).new
  end

  def cookies
    @cookies ||= HTTP::Cookies.from_headers(request.headers)
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
end
