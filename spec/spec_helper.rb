require 'bundler/setup'

Bundler.require :development, :test

require 'uspec'

Dir.chdir File.dirname(__FILE__)

require_relative '../lib/logsaber'

extend Uspec

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
