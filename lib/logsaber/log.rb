module Logsaber
  class Log
    class << self
      def create *args
        default_options = {
          output: $stdout, level: :info, appname: nil,
          formatter: Logsaber::Saber.new
        }

        output, level, appname, formatter = extract_options args, default_options, :output
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
        log.formatter = formatter

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
    attr_accessor :output, :level, :appname, :formatter

    SEVERITY_LEVELS ||= [:debug, :info, :warn, :error, :fatal]

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
