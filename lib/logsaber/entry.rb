module Logsaber
  class Entry
    def self.generate *args, &block
      new_entry = new *args, &block
      new_entry.generate
    end

    def initialize raw_details, &block
      @raw_details, @block = raw_details, block
    end
    attr :raw_details, :block

    def generate
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
