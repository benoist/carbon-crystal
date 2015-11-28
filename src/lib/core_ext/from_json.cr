def Set.new(pull : JSON::PullParser)
  ary = new
  new(pull) do |element|
    ary << element
  end
  ary
end

def Set.new(pull : JSON::PullParser)
  pull.read_array do
    yield T.new(pull)
  end
end

struct Set
  def to_json(io)
    if empty?
      io << "[]"
      return
    end

    io.json_array do |array|
      each do |element|
        array << element
      end
    end
  end
end
