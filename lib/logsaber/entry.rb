module Logsaber
  class Entry
    def self.create all_details, &block
      all_details << block.call if block
      new all_details.shift, Array(all_details)
    end

    def initialize primary, secondary
      @primary, @secondary = primary, secondary
    end
    attr :primary, :secondary

    def parse
      {
        label: label,
        info: info,
        primary: primary,
        secondary: secondary,
        object: value
       }
    end

    protected

    def value
      secondary.last || primary
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
        Array view primary
      else
        details
      end
    end

    def details
      secondary.map{|item| analyze item }
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
