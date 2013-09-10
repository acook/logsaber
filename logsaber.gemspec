# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logsaber/version'

Gem::Specification.new do |gem|
  gem.name          = 'logsaber'
  gem.version       = Logsaber::VERSION
  gem.authors       = ['Anthony Cook']
  gem.email         = ['anthonymichaelcook@gmail.com']
  gem.description   = %q{A logger for a more civilized age. Intelligent logs for your applications.}
  gem.summary       = %q{A logger for a more civilized age.}
  gem.homepage      = 'http://github.com/acook/logsaber'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'uspec'
end
