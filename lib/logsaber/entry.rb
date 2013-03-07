module Logsaber
  class Entry
    def initialize *details, &block
      @details = details
      @block = block
    end
    attr_accessor :details, :log, :block

    def extract_details details
      primary, secondary = details

      if details.length == 2 then
        [view(primary), analyze(secondary), secondary]
      elsif block? then
        [view(primary), view(secondary)]
      elsif viewable?(primary) then
        ['MSG', view(primary), primary]
      else
        ['OBJ', analyze(primary), primary]
      end
    end

    def view object
      return '' if object.nil? || object.empty?

      if viewable? object then
        object.to_s
      else
        object.inspect
      end
    end

    def viewable? object
      [String, Symbol, Numeric].any?{|klass| object.is_a? klass}
    end

    def analyze object
      object.is_a?(String) ? object : object.inspect
    end

    def block?
      !!block
    end

    def to_a
      label, info = extract_details details

      if block? then
        result = block.call

        info << ' | ' unless info.empty?
        info << view(result)
      end

      [label, info, result || info || label]
    end
    alias_method :to_ary, :to_a
  end
end
