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
        options.output = outputize options.output

        self.new *options
      end

      protected

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

    SEVERITY_LEVELS ||= [:debug, :info, :warn, :error, :fatal]

    def initialize output, level, appname, formatter
      @output, @level, @appname, @formatter = output, level, appname, formatter
    end

    attr_accessor :output, :level, :appname, :formatter

    SEVERITY_LEVELS.each do |method_name|
      eval <<-END_OF_METHOD
        def #{method_name} *args, &block
          log :#{method_name}, *args, &block
        end
      END_OF_METHOD
    end

    protected

    def log severity, *details
      return unless loggable? severity
      label, info, object = extract_details details, block_given?

      if block_given? then
        result = yield

        info << ' | ' unless info.empty?
        info << view(result)

        object = result
      end

      message = format severity, "#{label} : #{info}"
      output.puts message
      output.flush

      object
    end

    def format *args, &block
      formatter.appname = appname
      formatter.format *args, &block
    end

    def extract_details details, given_block
      primary, secondary, object = details

      if details.length == 2 then
        [view(primary), analyze(secondary), object || secondary]
      elsif given_block then
        [view(primary), view(secondary), object]
      elsif viewable?(primary) then
        ['MSG', view(primary), object || primary]
      else
        ['OBJ', analyze(primary), object || primary]
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

    def loggable? severity
      SEVERITY_LEVELS.index(severity) >= SEVERITY_LEVELS.index(level)
    end
  end
end
