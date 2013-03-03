require_relative 'spec_helper'

test_string = 'foo'

spec 'will output to a file, given a filename' do
  filename = './test_file.log'
  begin
    File.delete filename
  rescue Errno::ENOENT => e
    # ignore if file doesn't exist
  end

  log = Logomatic.new filename
  log.debug test_string

  contents = File.open(filename, 'r').gets
  contents.include?(test_string).tap{File.delete filename}
end

require 'stringio'
spec 'can use a StringIO' do
  stringio = StringIO.new

  log = Logomatic.new stringio
  log.debug test_string

  stringio.string.include? test_string
end

spec 'can use an IO' do
  output = capture do
    log = Logomatic.new $stdout
    log.debug test_string
  end

  output.include?(test_string) || output
end

log = Logomatic.new

spec 'has shortcut methods' do
  methods = [:debug, :info, :warn, :error, :fatal]
  has = methods.map do |m|
    log.respond_to?(m) && m
  end

  has.all? || methods - has
end

spec 'can tell you the current minimum log level' do
  log.min_level == :info || log.min_level
end
