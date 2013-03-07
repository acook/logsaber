module Logsaber
  class Entry
    def self.create all_details, &block
      all_details << block.call if block
      new all_details.length, all_details.shift, Array(all_details)
    end

    def initialize length, primary, secondary
      @length, @primary, @secondary = length, primary, secondary
    end
    attr :length, :primary, :secondary

    def parse
      [text, value]
    end

    protected

    def value
      secondary.last || primary
    end

    def text
      "#{label} : #{info}"
    end

    def label
      if !secondary.empty? then
        view primary
      elsif primary.is_a? String then
        'MSG'
      else
        'OBJ'
      end
    end

    def info
      if secondary.empty? then
        view primary
      else
        details
      end
    end

    def details
      secondary.map{|item| analyze item }.join ' | '
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
