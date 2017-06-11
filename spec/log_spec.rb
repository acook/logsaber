require_relative 'spec_helper'

def self.capture
  readme, writeme = IO.pipe
  pid = fork do
    $stdout.reopen writeme
    readme.close

    yield
  end

  writeme.close
  output = readme.read
  Process.waitpid(pid)

  output
end

test_string = 'foo'

spec 'will output to a file, given a filename' do
  filename = './test_file.log'
  begin
    File.delete filename
  rescue Errno::ENOENT => e
    # ignore if file doesn't exist
  end

  log = Logsaber.create filename
  log.info test_string

  contents = File.open(filename, 'r').gets
  contents.include?(test_string).tap{File.delete filename}
end

require 'stringio'
spec 'can use a StringIO' do
  stringio = StringIO.new

  log = Logsaber.create stringio
  log.info test_string

  stringio.string.include? test_string
end

spec 'can use an IO' do
  output = capture do
    log = Logsaber.create $stdout
    log.info test_string
  end

  output.include?(test_string) || output
end

@log = Logsaber.create

spec 'has shortcut methods' do
  methods = [:debug, :info, :warn, :error, :fatal]
  has = methods.map do |m|
    @log.respond_to?(m) && m
  end

  has.all? || methods - has
end

spec 'can tell you the current minimum log level' do
  @log.level == :info || @log.level
end


@output = StringIO.new
@log = Logsaber.create @output

def self.clear_log
  @output.truncate 0
  @output.rewind
end

def format label, info
  "[ INFO] #{Process.pid} | #{label} : #{info}"
end


spec 'basic usage' do
  clear_log

  @log.info test_string
  @output.string.include? format('MSG', test_string)
end

spec 'with details usage' do
  clear_log

  @log.info :test_string, test_string
  @output.string.include? format(:test_string, test_string)
end

spec 'object usage' do
  clear_log

  array = [1,2,3]
  @log.info array
  @output.string.include? format('OBJ', array.inspect)
end

spec 'basic block usage' do
  clear_log

  @log.info 'label' do
    'block'
  end
  @output.string.include?(format('label', 'block')) || @output.string
end

spec 'block with details usage' do
  clear_log

  @log.info 'label', 'details' do
    'block'
  end
  @output.string.include?(format('label', 'details | block')) || @output.string
end

spec 'accepts appname during creation' do
  clear_log

  log = Logsaber.create output: @output, appname: 'MyAwesomeApp'

  log.info 'ohai'
  @output.string.include?("[ INFO] MyAwesomeApp:#{Process.pid} | MSG : ohai") || @output.string
end

spec 'setting level to :off will prevent any logging' do
  output = capture do
    log = Logsaber.create level: :off

    log.debug 'debug'
    log.info 'info'
    log.warn 'warn'
    log.error 'error'
    log.fatal 'fatal'
  end

  output.empty? || output
end

spec 'there is no "off" method' do
  !@log.respond_to? :off
end

spec 'timestamp format is mutable' do
  clear_log

  @log.formatter.time_format = 'xxx%Yxxx'
  @log.info test_string
  @log.formatter.time_format = Logsaber::Formatter::DEFAULT_TIME_FORMAT

  match = @output.string.match /(xxx\d\d\d\dxxx) (#{Regexp.escape format('MSG', test_string)})/
  !match[0].nil? && !match[1].nil? || match rescue @output.string
end

spec 'Log#log allows many items' do
  clear_log

  @log.info :foo, '1', '2', '3'
  @output.string.include? format('foo', '1 | 2 | 3')
end

spec 'Log.create can take an array of outputs' do
  Logsaber::Log.create output: [StringIO.new, StringIO.new]
  true
end

spec 'Logging goes to every output' do
  s1 = StringIO.new
  s2 = StringIO.new

  text = 'What we display??'

  @log = Logsaber::Log.create output: [s1, s2]

  @log.error text

  s1.string.include?(text) && s2.string.include?(text) || s2.string
end


