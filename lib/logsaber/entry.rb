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

    def view object
      viewable?(object) ? object.to_s : object.inspect
    end

    def analyze object
      analyzeable?(object) ? object : object.inspect
    end

    def viewable? object
      object && (analyzeable?(object) || object.is_a?(Symbol))
    end

    def analyzeable? object
      object.is_a?(String) && !object.empty?
    end

  end
end
