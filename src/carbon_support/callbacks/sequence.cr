class CarbonSupport::Callbacks::CallbackSequence(T)
  def initialize(@block : Environment(T) ->)
    @before = [] of Callback::Before(T)
    @after = [] of Callback::After(T)
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
    CallbackSequence(T).new ->(environment : Environment(T)) do
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
