module Logsaber
  class Entry
    def initialize formatter
      @formatter = formatter
    end
    attr_accessor :formatter

    def generate severity, raw_details, &block
      raw_details << block.call if block

      details = Details.new raw_details
      text, object = compile details.cleanup
      message = formatter.format severity, text

      [message, object]
    end

    protected

    def compile details
      label = details.shift
      ["#{label} : #{details.join ' | '}", details.last || label]
    end
  end
end
