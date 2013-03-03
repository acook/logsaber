Logomatic
=========

A logger for a more civilized age.

Philosophy/Why Logomatic?
-------------------------

Logomatic is a lot like Ruby's built in Logger class,
but it is based on the real world experience of how I actually use loggers.

The biggest difference is Logomatic's intelligent output.

### Intelligent Logging

If you pass a single string argument to an event method Logomatic will just log that string without any frills.

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

...Logomatic will intelligently evaluate it and format your output sanely:

```
2013-03-02 21:20:04.715 [ INFO] 32981 | heavy : \"this could be resource intensive\" | 9999
```

Also, since blocks are lazy loaded, they won't be evaluated at all if the severity is below the log level threshold, this is really important if your debug output is resource intensive.

### Ruby Logger Limitations Surpassed

There's also some complaints about the native Logger than I address:

1. You can't specify the log level on instantiation
  - Logomatic lets you set the log level when you create it:
    `$log = Logomatic.create file, :warn`
  - But you can still change the default later:
    `$log.level = :info`
2. You must specify the "progname" for every event
  - Logomatic lets you set the app name when you create it:
    `$log = Logomatic.create file, :warn, 'MyApp'`
  - Or change it to something else at any time:
    `$log.appname = 'SomethingElse'`

Installation
------------

Add this line to your application's Gemfile:

    gem 'logomatic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logomatic

Setup
-----

Give it a filename and it will log to a file:

```ruby
$log = Logomatic.create './log/my_app.log'
```

Give it an IO and it will log to it:

```ruby
$log = Logomatic.create $stdout
```

Even give it a StringIO and it will log to that:

```ruby
require 'stringio'
stringio = StringIO.create

$log = Logomatic.create stringio
```

You can also set the log level on initialization (it's :info by default):

```ruby
$log = Logomatic.create $stdout, :debug
```

And you can optionally specify a program name:

```ruby
$log = Logomatic.create $stdout, :info, 'MyApp'
```

Usage
-----

Then you can use any of the logging commands:

`debug`, `info`, `warn`, `error`, or `fatal`

like this:

```ruby
$log.warn 'Something might be amiss here'
```

or this:

```ruby
$log.error 'PEBKAC', @user
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

    Anthony M. Cook 2013
