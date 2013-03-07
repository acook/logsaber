module Logsaber
  class Entry
    def initialize formatter
      @formatter = formatter
    end
    attr_accessor :formatter, :details, :block

    def generate severity, details, &block
      @severity = severity
      @details = details
      @block   = block

      label, info, object = compile
      message = formatter.format severity, "#{label} : #{info}"

      [message, object]
    end

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

    def compile
      label, info = extract_details details

      if block? then
        result = block.call

        info << ' | ' unless info.empty?
        info << view(result)
      end

      [label, info, result || info || label]
    end
  end
end