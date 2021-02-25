Logsaber
=========

A logger for a more civilized age.

Reference documentation for the [Latest Released](http://rubydoc.info/gems/logsaber/file/README.markdown) and [Edge Version](https://github.com/acook/logsaber#readme) is available.

[![Gem Version](https://img.shields.io/gem/v/logsaber.svg?style=for-the-badge)](https://rubygems.org/gems/logsaber/)
[![CircleCI](https://img.shields.io/circleci/build/github/acook/logsaber?style=for-the-badge&token=de887bd244ab55306432fef45b8307ef4c18075c)](https://app.circleci.com/pipelines/github/acook/logsaber)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/acook/logsaber?style=for-the-badge)](https://codeclimate.com/github/acook/logsaber)

Philosophy / Why Logsaber?
--------------------------

Logsaber is a lot like Ruby's built in [Logger](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html) class,
but it is based on the real world experience of how I actually use loggers.

The biggest difference is Logsaber's intelligent output.

### Intelligent Logging

If you pass a single string argument to an event method Logsaber will just log that string without any frills.

But if you pass it an object like an Array:

```ruby
array = [1,2,3]
$log.info array
```

...it will inspect the array and the output will reflect the intent:

```
2013-03-02 21:08:30.797 [ INFO] 32981 | OBJ : [1, 2, 3]
```

Even better, if you pass in two arguments, like this:

```ruby
$log.info 'using environment', ENV['MYAPP_ENV']
```

...the first will be treated as a label, and the second as an object to be inspected:

```
2013-03-02 20:11:22.630 [ INFO] 31395 | using environment : development
```

If you pass in a block:

```ruby
@log.info :heavy, 'this could be resource intensive' do
  10000.times.to_a.last
end
```

...Logsaber will intelligently evaluate it and format your output sanely:

```
2013-03-02 21:20:04.715 [ INFO] 32981 | heavy : "this could be resource intensive" | 9999
```

Also, since blocks are lazy loaded, they won't be evaluated at all if the severity is below the log level threshold,
this is really important if your debug output is resource intensive.

### Ruby Logger Limitations Surpassed

There's also some complaints about the native Logger than I address:

1. You can't specify the log level on instantiation.

  Logsaber lets you set the log level when you create it:

  ```ruby
  $log = Logsaber.create level: :warn
  ```

  But you can still change the default later:

  ```ruby
  $log.level = :info
  ```

2. You must specify the "progname" for every event.

  Logsaber lets you set your app's name when you create it:

  ```ruby
  $log = Logsaber.create appname: 'MyApp'
  ```

  Or change it to something else at any time:

  ```ruby
  $log.appname = 'SomethingElse'
  ```

  ...and the output will look like this:

  ```
  2013-03-03 16:50:43.595 [ INFO] SomethingElse:8881 | MSG : ohai
  ```

Installation
------------

Use [Bundler](http://gembundler.com):

```ruby
# in your Gemfile
gem 'logsaber'
```

Setup
-----

Give it a filename and it will log to a file:

```ruby
$log = Logsaber.create './log/my_app.log'
```

Or you log to an IO (`$stdout` is the default, good for debugging):

```ruby
$log = Logsaber.create $stdout
```

It can even log to a StringIO (good for test environments):

```ruby
require 'stringio'
stringio = StringIO.create

$log = Logsaber.create stringio
```

You can also set the log level on initialization (it's `:info` by default):

```ruby
$log = Logsaber.create level: :debug
```

And you can optionally specify the name of your app (which is `nil` by default, it's displayed next to the pid in the output):

```ruby
$log = Logsaber.create appname: 'MyApp'
```

Example with all options:

```ruby
Logsaber.create 'my_app.log', level: :debug, appname: 'MyApp'
```

Usage
-----

Then you can use any of the logging commands:

`debug`, `info`, `warn`, `error`, or `fatal`

like this:

```ruby
$log.warn 'Something might be amiss here'
```

or like this:

```ruby
$log.error 'PEBKAC', @user
```

or maybe:

```ruby
@log.debug "What is this I don't even." do
  big_data.inspect
end
```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Author
======

    Anthony M. Cook 2013-2021
