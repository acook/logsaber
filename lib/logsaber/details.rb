module Logsaber
  class Details
    def initialize details
      @details = details
      @primary, @secondary, *_ = details
    end
    attr :details, :primary, :secondary

    def cleanup
      if details.length > 1 then
        [view(primary)] + details[1..-1].map{|item| analyze(item)}
      elsif viewable? primary then
        ['MSG', view(primary)]
      else
        ['OBJ', analyze(primary)]
      end
    end

    def analyze object
      object.is_a?(String) ? object : object.inspect
    end

    def view object
      if object.nil? || object.empty? || viewable?(object) then
        object.to_s
      else
        object.inspect
      end
    end

    def viewable? object
      [String, Symbol, Numeric].any?{|klass| object.is_a? klass}
    end
  end
end
