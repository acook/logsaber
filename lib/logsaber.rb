require 'logsaber/version'
require 'logsaber/saber'
require 'logsaber/log'
require 'logsaber/options'

module Logsaber
  def self.create *args, &block
    Log.create *args, &block
  end
end
