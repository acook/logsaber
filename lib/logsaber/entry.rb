module Logsaber
  class Entry
    def initialize formatter
      @formatter = formatter
    end
    attr_accessor :formatter

    def generate severity, raw_details, &block
      raw_details << block.call if block
      details = Details.cleanup raw_details

      text = compile *details
      message = formatter.format severity, text

      [message, details.last || label]
    end

    protected

    def compile label, *details
      "#{label} : #{details.join ' | '}"
    end
  end
end
