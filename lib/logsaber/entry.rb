module Logsaber
  class Entry
    def self.create details, &block
      details << block.call if block
      new details.length, details.shift, *details
    end

     def initialize *details
      @length  = details.shift
      @label   = details.shift
      @details = Array(details)
    end
    attr :length, :label, :details

    def generate
      text = compile *clean_details

      [text, details.last]
    end

    protected

    def compile label, *details
      "#{label} : #{details.join ' | '}"
    end

    def clean_details
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
