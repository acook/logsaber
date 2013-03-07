module Logsaber
  class Details
    def initialize details, block
      @details = details
      @primary, @secondary, *_ = details
      @block = block
    end
    attr :details, :block, :primary, :secondary

    def cleanup
      extract
    end

    def extract
      if details.length == 2 then
        [view(primary), analyze(secondary), secondary]
      elsif block then
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
  end
end
