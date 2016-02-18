module Carbon
  struct Environment
    def initialize(@env)
    end

    {% for env in ["development", "test", "production"] %}
      def {{env.id}}?
        @env == {{env}}
      end
    {% end %}
  end

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
      logger.level = env.development? ? Logger::DEBUG : Logger::INFO
    end
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.env
    @@env = Environment.new(ENV["CARBON_ENV"])
  end
end
