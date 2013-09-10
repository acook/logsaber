require_relative 'spec_helper'

spec 'does stuff' do
  stringio = StringIO.new
  log = Logsaber.create stringio

  log.info 5
  expecting = /20\d\d-\d\d-\d\d \d\d:\d\d:\d\d.\d\d\d \[ INFO\] #{Process.pid} \| OBJ : 5\n/
  actual    = stringio.tap(&:rewind).read
  match     = expecting.match actual

  !!match || match
end
