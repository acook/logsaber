require 'logsaber/version'

class Logsaber
  @default_options = {output: $stdout, level: :info, appname: nil}

  class << self
    attr :default_options

    def create *args
      output, level, appname = extract_options args, default_options, :output
      log = self.new

      log.output =
        if output.is_a? String then
          File.new output, 'a'
        elsif output.respond_to? :puts then
          output
        else
          raise "invalid output object: #{output.inspect}"
        end

      log.level = level
      log.appname = appname

      log
    end

    protected

    def extract_options args, defaults, primary
      options =
        if args.last.is_a? Hash then
          args.pop
        else
          Hash.new
        end
      options[primary] = args.shift if args.first
      defaults.merge(options).values_at *defaults.keys
    end
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

  def color!
    @color = true
  end

  def no_color!
    @color = false
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
    %Q{#{color severity}#{timestamp} [#{severity_info severity}] #{process_info} | #{contents}#{esc 0}}
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
