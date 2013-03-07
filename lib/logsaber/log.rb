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
      @output = outputize output
      @level, @appname, @formatter = level.to_sym, appname, formatter

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

    def log severity, *details
      return unless loggable? severity
      label, info = extract_details details, block_given?

      if block_given? then
        result = yield

        info << ' | ' unless info.empty?
        info << view(result)
      end

      message = format severity, "#{label} : #{info}"
      output.puts message
      output.flush

      object = result || info
    end

    def format *args, &block
      formatter.appname = appname
      formatter.format *args, &block
    end

    def extract_details details, given_block
      primary, secondary = details

      if details.length == 2 then
        [view(primary), analyze(secondary), secondary]
      elsif given_block then
        [view(primary), view(secondary)]
      elsif viewable?(primary) then
        ['MSG', view(primary), primary]
      else
        ['OBJ', analyze(primary), primary]
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
