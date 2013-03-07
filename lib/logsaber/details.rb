module Logsaber
  class Details
    def self.cleanup details
      new_details = new details
      new_details.cleanup
    end

    def initialize details
      @length  = details.length
      @label   = details.shift
      @details = details
    end
    attr :length, :label, :details

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
