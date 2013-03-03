require 'bundler/setup'

Bundler.require :development, :test

require 'uspec'

Dir.chdir File.dirname(__FILE__)

require_relative '../lib/logomatic'

extend Uspec

