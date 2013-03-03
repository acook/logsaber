require_relative 'spec_helper'

test_string = 'foo'

spec 'will output to a file, given a filename' do
  filename = './test_file.log'
  begin
    File.delete filename
  rescue Errno::ENOENT => e
    # ignore if file doesn't exist
  end

  log = Logomatic.create filename
  log.debug test_string

  contents = File.open(filename, 'r').gets
  contents.include?(test_string).tap{File.delete filename}
end

require 'stringio'
spec 'can use a StringIO' do
  stringio = StringIO.new

  log = Logomatic.create stringio
  log.debug test_string

  stringio.string.include? test_string
end

spec 'can use an IO' do
  output = capture do
    log = Logomatic.create $stdout
    log.debug test_string
  end

  output.include?(test_string) || output
end

@log = Logomatic.create

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
@log = Logomatic.create @output

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

spec ' with details usage' do
  clear_log

  @log.info :test_string, test_string
  @output.string.include? format(:test_string, test_string.inspect)
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
  @output.string.include?(format('label', '"details" | block')) || @output.string
end

