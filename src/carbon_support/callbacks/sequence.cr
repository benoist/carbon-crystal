class CarbonSupport::Callbacks::CallbackSequence
  def initialize(@block : Environment -> CarbonSupport::Callbacks::Environment)
    @before = [] of Callback::Before
    @after = [] of Callback::After
  end

  def before(callback)
    @before.unshift(callback)
    self
  end

  def after(callback)
    @after.push(callback)
    self
  end

  def around(callback)
    CallbackSequence.new ->(environment : Environment) do
      proc = ->{ self.call(environment) }
      callback.call(environment, proc)
    end
  end

  def call(environment)
    @before.each { |b| b.call(environment) }
    value = @block.call(environment)
    @after.each { |b| b.call(environment) }
    value
  end
end
