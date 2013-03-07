module Logsaber
  class Formatter
    DEFAULT_TIME_FORMAT ||= '%Y-%m-%d %H:%M:%S.%L'

    def initialize color = nil
      @color = color
    end
    attr_accessor :time_format, :log, :color

    def set_log new_log
      self.log = new_log
      self
    end

    def time_format
      @time_format ||= DEFAULT_TIME_FORMAT
    end

    def color!
      @color = SimpleColor.new
    end

    def color?
      !!@color
    end

    def format severity, contents
      index = log.class::SEVERITY_LEVELS.index(severity)
      text  = layout severity, contents

      if color? then
        color.colorize index, text
      else
        text
      end
    end

    def layout severity, contents
      %(#{timestamp} [#{severity_info severity}] #{process_info} | #{contents})
    end

    def timestamp
      Time.now.strftime time_format
    end

    def severity_info severity
      severity.to_s.upcase.rjust 5
    end

    def process_info
      pid = Process.pid.to_s
      appname? ? "#{appname}:#{pid}" : pid
    end

    def appname?
      !!appname
    end

    def appname
      log.appname
    end
  end
end
