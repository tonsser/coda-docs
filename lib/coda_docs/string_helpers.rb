module StringHelpers
  class << self
    def camelize(string)
      parts = string.split("_")
      parts[0] + parts[1..-1].map { |part| upcase_first(part) }.join
    end

    def upcase_first(string)
      string[0].upcase + string[1..-1]
    end
  end
end
