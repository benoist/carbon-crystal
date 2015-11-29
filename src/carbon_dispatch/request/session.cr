module CarbonDispatch
  class Request
    class Session
      def initialize(@cookie_jar)
        @session = get_cookie
        @session["_id"] ||= SecureRandom.uuid
      end

      def id
        @session["_id"]
      end

      def destroy
        @session.clear
      end

      def [](key)
        @session[key]
      end

      def has_key?(key)
        @session.has_key?(key)
      end

      def keys
        @session.keys
      end

      def values
        @session.values
      end

      def []=(key, value)
        @session[key] = value.to_s
      end

      def to_hash
        @session
      end

      def update(hash : Hash(String, String))
        @session.update(hash)
      end

      def delete(key)
        @session.delete(key) if has_key?(key)
      end

      def fetch(key, default = nil)
        @session.fetch(key, default)
      end

      def empty?
        @session.empty?
      end

      def set_cookie
        @cookie_jar.encrypted["_session"] = @session.to_json
      end

      def get_cookie
        Hash(String, String).from_json(@cookie_jar.encrypted["_session"] || "{}")
      rescue e : JSON::ParseException
        Hash(String, String).new
      end
    end
  end
end
