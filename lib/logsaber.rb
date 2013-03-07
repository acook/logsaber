require 'logsaber/version'
require 'logsaber/saber'
require 'logsaber/log'

module Logsaber
  def self.create *args, &block
    Log.create *args, &block
  end
end
