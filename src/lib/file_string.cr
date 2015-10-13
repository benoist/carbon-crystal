class FileString
  def initialize(@string)
  end

  def join(*other)
    FileString.new(File.join(@string.to_s, *other.map(&.to_s)))
  end

  def to_s
    @string
  end
end
