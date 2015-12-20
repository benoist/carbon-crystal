class Object
  def blank?
    if self.responds_to?(:empty?)
      !!self.empty?
    else
      !self
    end
  end

  def present?
    !blank?
  end

  def presence
    if present?
      self
    end
  end
end
