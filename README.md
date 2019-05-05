# RediSearch

[![Build Status](https://travis-ci.com/npezza93/redi_search.svg?branch=master)](https://travis-ci.com/npezza93/redi_search)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c6437acac5684de2549d/test_coverage)](https://codeclimate.com/github/npezza93/redi_search/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/c6437acac5684de2549d/maintainability)](https://codeclimate.com/github/npezza93/redi_search/maintainability)

A simple, but powerful Ruby wrapper around RediSearch,
a search engine on top of Redis.

## Installation

Firstly, Redis and RediSearch need to be installed.

You can download Redis from https://redis.io/download, and check out installation instructions [here](https://github.com/antirez/redis#installing-redis). Alternatively, on macOS or Linux you can install via Homebrew.

To install RediSearch:
1. git clone https://github.com/RedisLabsModules/RediSearch.git
1. cd RediSearch
1. mkdir build
1. cd build
1. cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
1. make
1. redis-server --loadmodule ./redisearch.so or load the module in your redis.conf

You can also checkout [here](https://oss.redislabs.com/redisearch/Quick_Start.html) for more detailed installation instructions. If you already have a redis-server running you can also update your redis.conf file to always load the redisearch module. (On macOS the redis.conf file can be found `/usr/local/etc/redis.conf`)


After Redis and RediSearch are up and running, add this line to your application's Gemfile:

```ruby
gem 'redi_search'
```

And then execute:
```bash
❯ bundle
````

Or install it yourself as:
```bash
❯ gem install redi_search
```

and require it:
```ruby
require 'redi_search'
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. You can also start a rails console if you `cd` into `test/dummy`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, execute `bin/publish (major|minor|patch)` which will update the version number in `version.rb`, create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/npezza93/redi_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RediSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npezza93/redi_search/blob/master/CODE_OF_CONDUCT.md).
