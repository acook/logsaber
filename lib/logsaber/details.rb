module Logsaber
  class Details
    def initialize details
      @length  = details.length
      @label   = details.shift
      @details = details
    end
    attr :label, :details, :length

    def cleanup
      if length > 1 then
        [view(label)] + details.map{|item| analyze(item)}
      elsif viewable? label then
        ['MSG', view(label)]
      else
        ['OBJ', analyze(label)]
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
