module Logsaber
  class Saber
    DEFAULT_TIME_FORMAT ||= '%Y-%m-%d %H:%M:%S.%L'

    attr_accessor :time, :appname

    def level= new_level
      @level = new_level if SEVERITY_LEVELS.include? new_level
    end

    def time_format
      @time_format ||= DEFAULT_TIME_FORMAT
    end

    def color!
      @color = true
    end

    def no_color!
      @color = false
    end

    def format severity, contents
      %Q{#{color severity}#{timestamp} [#{severity_info severity}] #{process_info} | #{contents}#{esc 0 if color?}}
    end

    def color severity
      return unless color?

      esc [31, 0, 33, 31, '31;1'][SEVERITY_LEVELS.index(severity)]
    end

    def esc seq
      "\e[#{seq}m"
    end

    def color?
      !!@color
    end

    def process_info
      pid = Process.pid.to_s
      appname? ? "#{appname}:#{pid}" : pid
    end

    def severity_info severity
      severity.to_s.upcase.rjust 5
    end

    def timestamp
      Time.now.strftime time_format
    end

    def appname?
      !!@appname
    end
  end
end
