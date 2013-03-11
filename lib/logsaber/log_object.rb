module Logsaber
  class LogObject
    def self.collection objects
      objects.map do |object|
        new object
      end
    end

    def initialize object
      @object = object
    end

    def view
      viewable? ? object.to_s : object.inspect
    end

    def analyze
      analyzeable? ? object : object.inspect
    end

    def viewable?
      object && (analyzeable? || object.is_a?(Symbol))
    end

    def analyzeable? object
      object.is_a?(String) && !object.empty?
    end

    def join other
      "#{analyze} | #{other.to_s}"
    end

    def to_s
      analyze
    end
  end
end
