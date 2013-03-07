module Logsaber
  class Entry
    def generate raw_details, &block
      raw_details << block.call if block
      details = Details.cleanup raw_details

      text = compile *details

      [text, details.last]
    end

    protected

    def compile label, *details
      "#{label} : #{details.join ' | '}"
    end
  end
end
