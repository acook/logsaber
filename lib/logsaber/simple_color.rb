module Logsaber
  class SimpleColor
    attr_accessor :colors

    def colorize index, text = nil, &block
      "#{color index}#{text || yield}#{esc 0}"
    end

    def color index
      esc colors[index]
    end

    def colors
      @colors = [31, 0, 33, 31, '31;1']
    end

    def esc seq
      "\e[#{seq}m"
    end
  end
end
