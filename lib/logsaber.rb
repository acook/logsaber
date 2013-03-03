require 'logomatic/version'

class Logomatic
  def self.create new_output = $stdout, new_level = :info, new_appname = nil
    log = self.new

    log.output =
      if new_output.is_a? String then
        File.new new_output, 'a'
      else
        new_output
      end

    log.level = new_level
    log.appname = new_appname

    log
  end
  attr_accessor :output, :level, :appname, :time_format

  DEFAULT_TIME_FORMAT ||= '%Y-%m-%d %H:%M:%S.%L'
  SEVERITY_LEVELS ||= [:debug, :info, :warn, :error, :fatal]

  SEVERITY_LEVELS.each do |method_name|
    eval <<-END_OF_METHOD
      def #{method_name} *args, &block
        log :#{method_name}, *args, &block
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

  def log severity, *details
    return unless loggable? severity
    label, info, object = extract_details details, block_given?

    if block_given? then
      result = yield

      info << ' | ' unless info.empty?
      info << result.to_s

      object = result
    end

    message = format severity, "#{label} : #{info}"
    output.puts message
    output.flush

    object
  end

  def extract_details details, given_block
    primary, secondary, object = details

    if details.length == 2 then
      [primary.to_s, secondary.inspect, object || secondary]
    elsif given_block then
      [primary, secondary.to_s, object]
    elsif [String, Numeric].any?{|klass| primary.is_a? klass} then
      ['MSG', primary, object || primary]
    else
      ['OBJ', primary.to_s, object || primary]
    end
  end

  def loggable? severity
    SEVERITY_LEVELS.index(severity) >= SEVERITY_LEVELS.index(level)
  end

  def format severity, contents
    %Q{#{timestamp} [#{severity_info severity}] #{process_info} | #{contents}}
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
