require 'logsaber/version'
require 'logsaber/formatter'
require 'logsaber/log'
require 'logsaber/options'
require 'logsaber/entry'

module Logsaber
  def self.create *args, &block
    Log.create *args, &block
  end
end
