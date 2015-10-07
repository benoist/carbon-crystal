class CarbonDispatch::Request
  getter :request

  delegate :path, @request
  delegate :method, @request
  delegate :headers, @request

  def initialize(@request)
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
