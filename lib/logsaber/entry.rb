module Logsaber
  class Entry
    def initialize formatter
      @formatter = formatter
    end
    attr_accessor :formatter

    def generate severity, raw_details, &block
      details = Details.new raw_details, !!block

      label, info, object = compile details.cleanup, block
      message = formatter.format severity, "#{label} : #{info}"

      [message, object]
    end

    def compile details, block
      label, info, *_ = details

      if block then
        result = block.call

        info << ' | ' unless info.empty?
        info << result.to_s
      end

      [label, info, result || info || label]
    end
  end
end
