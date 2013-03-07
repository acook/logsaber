module Logsaber
  class Options < OpenStruct
    def self.extract_from args, defaults = {}, primary = nil
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      options[primary] = args.shift if primary && args.first

      new defaults.merge(options)
    end

    def to_a
      @table.values
    end
    alias_method :to_ary, :to_a
  end
end
