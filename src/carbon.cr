module Carbon
  enum Environment
    Development
    Test
    Production
  end

  def self.application=(app)
    @@application = app
  end

  def self.application
    @@application || raise "Application not created"
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
        io <<  message
      end
      logger.level = env.development? ? Logger::DEBUG : Logger::INFO
    end
  end

  def self.env
    Environment::Development
  end
end
