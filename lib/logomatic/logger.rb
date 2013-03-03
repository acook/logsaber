module Logomatic
  def initialize logfile = 'logomatic.log', min_level = :info
    @output = File.new logfile, 'a'
    self.min_level = min_level
  end
  attr_accessor :output, :level, :min_level

  LEVELS ||= [:debug, :info, :warn, :error, :fatal]

  LEVELS.each do |method_name|
    eval <<-END_OF_METHOD
      def #{method_name} key, value = nil, &block
        log :#{method_name}, key, value, &block
      end
    END_OF_METHOD
  end

  def min_level= new_min_level
    @min_level = new_min_level if LEVELS.include? new_min_level
  end

  protected

  def log level, key, value = nil
    if value then
      label = key.to_s
      info = value.inspect
    else
      label = 'MSG'
      info  = key
    end

    if block_given? && loggable?(level) then
      result = yield
      info << " | " unless info.empty?
      info << result
    end

    message = format level, "#{label} : #{info}"
    output.puts message
    output.flush

    result = result || value || key
  end

  def loggable? level
    LEVELS.index(level) >= LEVELS.index(min_level)
  end

  def format level, contents
    %Q{#{timestamp} [#{"#{level}".upcase.rjust(5)}] #{Process.pid} | #{contents}}
  end

  def timestamp
    Time.now.to_s
  end
end
