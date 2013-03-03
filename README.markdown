Logomatic
=========

A simple little log system.

Installation
------------

Add this line to your application's Gemfile:

    gem 'logomatic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logomatic

Usage
-----

Give it a filename and it will log to a file:

```ruby
$log = Logomatic.new './log/my_app.log'
```

Give it an IO and it will log to it:

```ruby
$log = Logomatic.new $stdout
```

Even give it a StringIO and it will log to that:

```ruby
require 'stringio'
stringio = StringIO.new

$log = Logomatic.new stringio
```

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
