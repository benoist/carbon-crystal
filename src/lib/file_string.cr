class FileString
  def initialize(@string)
  end

  def join(*other)
    FileString.new(File.join(@string, *other))
  end

  def to_s
    @string
  end
end
