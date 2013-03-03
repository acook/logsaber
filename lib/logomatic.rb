require 'logomatic/version'

class Logomatic
  def initialize log = $stdout, new_level = :info, new_appname = nil
    @output = log.is_a?(String) ? File.new(log, 'a') : log
    self.level = new_level
    self.appname = new_appname
  end
  attr_accessor :output, :level, :appname, :time_format

  DEFAULT_TIME_FORMAT = '%Y-%m-%d %H:%M:%S.%L'
  SEVERITY_LEVELS ||= [:debug, :info, :warn, :error, :fatal]

  SEVERITY_LEVELS.each do |method_name|
    eval <<-END_OF_METHOD
      def #{method_name} key, value = nil, &block
        log :#{method_name}, key, value, &block
      end
    END_OF_METHOD
  end

  def level= new_level
    @level = new_level if SEVERITY_LEVELS.include? new_level
  end

  def time_format
    @time_format ||= DEFAULT_TIME_FORMAT
  end

  protected

  def log severity, key, value = nil
    if value then
      label = key.to_s
      info = value.inspect
    else
      label = 'MSG'
      info  = key
    end

    if block_given? && loggable?(severity) then
      result = yield
      info << " | " unless info.empty?
      info << result
    end

    message = format severity, "#{label} : #{info}"
    output.puts message
    output.flush

    result = result || value || key
  end

  def loggable? severity
    SEVERITY_LEVELS.index(severity) >= LEVELS.index(level)
  end

  def format level, contents
    %Q{#{timestamp} [#{level_info}] #{process_info} | #{contents}}
  end

  def process_info
    pid = Process.pid.to_s
    appname? ? "#{appname}:#{pid}" : pid
  end

  def level_info
    level.to_s.upcase.rjust 5
  end

  def timestamp
    Time.now.strftime time_format
  end

  def appname?
    !!@appname
  end
end
