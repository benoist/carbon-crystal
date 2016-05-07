module Carbon
  struct Environment
    def initialize(@env : String)
    end

    {% for env in ["development", "test", "production"] %}
      def {{env.id}}?
        @env == {{env}}
      end
    {% end %}

    def to_s(io : IO)
      @env.to_s(io)
    end
  end

  @@logger : Logger?

  def self.application=(app)
    @@application = app
  end

  def self.application
    @@application || raise "Application not created"
  end

  def self.key_generator=(key_generator)
    @@key_generator = key_generator
  end

  def self.key_generator
    @@key_generator || raise "Key generator not defined"
  end

  def self.root=(root)
    @@root = FileString.new(root)
  end

  def self.root
    @@root || raise "Root is not defined"
  end

  def self.logger
    @@logger ||= Logger.new(STDOUT).tap do |logger|
      logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        io << message
      end
      logger.level = log_level
    end
  end

  def self.log_level
    @@log_level ||= env.development? ? Logger::DEBUG : Logger::INFO
  end

  def self.log_level=(level : Logger::Severity)
    @@log_level = level
    puts "LogLevel set to: #{level}"
    logger.level = level
  end

  def self.log_level=(level : String)
    self.log_level = case level.upcase
                     when "ERROR"
                       Logger::ERROR
                     when "INFO"
                       Logger::INFO
                     else
                       Logger::DEBUG
                     end
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.env
    @@env = Environment.new(ENV["CARBON_ENV"]? || "development")
  end
end
