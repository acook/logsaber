module Logsaber
  class Log
    class << self
      def create *args
        default_options = {
          output: $stdout,
          level: :info,
          appname: nil,
          formatter: Logsaber::Saber.new
        }
        options = Options.extract_from args, default_options, :output

        self.new *options
      end
    end

    SEVERITY_LEVELS ||= [:debug, :info, :warn, :error, :fatal, :off]

    def initialize output, level, appname, formatter
      @output    = outputize output
      @level     = level.to_sym
      @appname   = appname
      @formatter = formatter.set_log self

      unless SEVERITY_LEVELS.include? @level then
        raise "Invalid level: #{level.inspect}.\nUse one of: #{SEVERITY_LEVELS}"
      end
    end

    attr_accessor :output, :level, :appname, :formatter

    SEVERITY_LEVELS.each do |method_name|
      next if method_name == :off

      eval <<-END_OF_METHOD
        def #{method_name} *args, &block
          log :#{method_name}, *args, &block
        end
      END_OF_METHOD
    end

    protected

    def log severity, *details, &block
      return unless loggable? severity

      label, info, object = *Entry.new(*details, &block)

      message = format severity, "#{label} : #{info}"
      output.puts message
      output.flush

      object
    end

    def format *args, &block
      formatter.format *args, &block
    end

    def loggable? severity
      SEVERITY_LEVELS.index(severity) >= SEVERITY_LEVELS.index(level)
    end

    def outputize new_output
      if new_output.is_a? String then
        File.new new_output, 'a'
      elsif new_output.respond_to? :puts then
        new_output
      else
        raise "invalid output object: #{new_output.inspect}"
      end
    end
  end
end
