require 'logomatic/version'

class Logomatic
  def initialize logfile = 'logomatic.log', level = :info
    @output = logfile.is_a?(String) ? File.new(logfile, 'a') : logfile
    self.level = level
  end
  attr_accessor :output, :level

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
    %Q{#{timestamp} [#{"#{level}".upcase.rjust(5)}] #{Process.pid} | #{contents}}
  end

  def timestamp
    Time.now.to_s
  end
end
