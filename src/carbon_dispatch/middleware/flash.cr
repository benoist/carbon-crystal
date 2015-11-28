module CarbonDispatch # :nodoc:
  class Request
    def flash
      @flash_hash ||= Flash::FlashHash.from_session_value(session.fetch("_flash", "{}"))
    end
  end

  class Flash
    include Middleware

    class FlashNow
      property :flash

      def initialize(flash)
        @flash = flash
      end

      def []=(key, value)
        @flash[key] = value
        @flash.discard(key)
        value
      end

      def [](k)
        @flash[k.to_s]
      end

      # Convenience accessor for <tt>flash.now["alert"]=</tt>.
      def alert=(message)
        self["alert"] = message
      end

      # Convenience accessor for <tt>flash.now["notice"]=</tt>.
      def notice=(message)
        self["notice"] = message
      end
    end

    class FlashHash
      JSON.mapping({
        flashes: Hash(String, String),
        discard: Set(String),
      })

      def self.from_session_value(json)
        from_json(json).tap(&.sweep)
      rescue e : JSON::ParseException
        new
      end

      def initialize
        @flashes = Hash(String, String).new
        @discard = Set(String).new
      end

      def discard=(value : Array(String))
        @discard = value.to_set
      end

      def []=(key, value)
        discard.delete key
        @flashes[key] = value
      end

      def [](key)
        @flashes[key]?
      end

      def update(hash : Hash(String, String)) # :nodoc:
        @discard.subtract hash.keys
        @flashes.update hash
        self
      end

      def keys
        @flashes.keys
      end

      def has_key?(key)
        @flashes.has_key?(key)
      end

      def delete(key)
        @discard.delete key
        @flashes.delete key
        self
      end

      def to_hash
        @flashes.dup
      end

      def empty?
        @flashes.empty?
      end

      def clear
        @discard.clear
        @flashes.clear
      end

      def now
        @now ||= FlashNow.new(self)
      end

      def keep(key = nil)
        key = key.to_s if key
        @discard.subtract key
        key ? self[key] : self
      end

      def discard(key = nil)
        keys = key ? [key] : self.keys
        @discard.merge keys
        key ? self[key] : self
      end

      def sweep
        @discard.each { |k| @flashes.delete k }
        @discard.clear
        @discard.merge @flashes.keys
      end

      def alert
        self["alert"]
      end

      def alert=(message)
        self["alert"] = message
      end

      def notice
        self["notice"]
      end

      def notice=(message)
        self["notice"] = message
      end

      def to_session
        {"flashes": @flashes, "discard": @discard}.to_json
      end
    end

    def call(request : Request, response)
      app.call(request, response)
    ensure
      session = request.session
      flash = request.flash.not_nil!

      session["_flash"] = flash.to_session
    end
  end
end
