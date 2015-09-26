module Carbon
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
    @@logger ||= Logger.new(STDOUT)
  end
end
