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
1. `git clone https://github.com/RedisLabsModules/RediSearch.git`
1. `cd RediSearch`
1. `mkdir build`
1. `cd build`
1. `cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo`
1. `make`
1. `redis-server --loadmodule ./redisearch.so or load the module in your redis.conf`

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

### Configuration
```ruby
RediSearch.configure do |config|
  config.redis_config = {
    host: "127.0.0.1",
    port: "6379"
  }
end
```

### Index

All actions revolve around indexes. To instantiate one:
```ruby
RediSearch::Index.new(name_of_index, schema)
```
The name is a string identifying the index and the schema is the argument is a hash that defines all the fields in an index. Each field can be one of four types: geo, numeric, tag, or text.

#### Text field options
- *weight* (default: 1.0)
  - Declares the importance of this field when calculating result accuracy. This is a multiplication factor.
  - Ex: `{ name: { text: { weight: 2 } } }`
- *phonetic*
  - Will perform phonetic matching on field in searches by default. The obligatory {matcher} argument specifies the phonetic algorithm and language used. The following matchers are supported:
    - dm:en - Double Metaphone for English
    - dm:fr - Double Metaphone for French
    - dm:pt - Double Metaphone for Portuguese
    - dm:es - Double Metaphone for Spanish
  - Ex: `{ name: { text: { phonetic: 'dm:en' } } }`
- *sortable* (default: false)
  -  Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).
  - Ex: `{ name: { text: { sortable: true } } }`
- *no_index* (default: false)
  - Field will not be indexed. This is useful in conjunction with `sortable`, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has `no_index` and doesn't have `sortable`, it will just be ignored by the index.
  - Ex: `{ name: { text: { no_index: true } } }`
- *no_stem* (default: false)
  - Disable stemming when indexing its values. This may be ideal for things like proper names.
  - Ex: `{ name: { text: { no_stem: true } } }`

#### Numeric field options
- *sortable* (default: false)
  -  Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).
  - Ex: `{ id: { numeric: { sortable: true } } }`
- *no_index* (default: false)
  - Field will not be indexed. This is useful in conjunction with `sortable`, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has `no_index` and doesn't have `sortable`, it will just be ignored by the index.
  - Ex: `{ id: { numeric: { no_index: true } } }`

#### Tag field options
- *sortable* (default: false)
  -  Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).
  - Ex: `{ tag: { tag: { sortable: true } } }`
- *no_index* (default: false)
  - Field will not be indexed. This is useful in conjunction with `sortable`, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has `no_index` and doesn't have `sortable`, it will just be ignored by the index.
  - Ex: `{ tag: { tag: { no_index: true } } }`
- *separator* (default: ",")
  - Indicates how the text contained in the field is to be split into individual tags. The default is ,. The value must be a single character.
  - Ex: `{ tag: { tag: { separator: ',' } } }`

#### Geo field options
- *sortable* (default: false)
  -  Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).
  - Ex: `{ place: { geo: { sortable: true } } }`
- *no_index* (default: false)
  - Field will not be indexed. This is useful in conjunction with `sortable`, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has `no_index` and doesn't have `sortable`, it will just be ignored by the index.
  - Ex: `{ place: { geo: { no_index: true } } }`

Some of the commands that are available on an index are as follows:
- *create*
  - creates the index in the Redis instance, returns a boolean. Has an accompanying bang method that will raise an exception upon failure.
- *drop*
  - drops the index from the Redis instance, returns a boolean. Has an accompanying bang method that will raise an exception upon failure.
- *exist?*
  - Returns a boolean signifying indexes existence.
- *info*  
  - Returns a hash with all the information for the index
- *fields*
  - Returns an array of field names in the index
- *add*
  - Takes an object as the first argument and a second argument that is a score (a value between 0.0 and 1.0). The object passed must respond to all the fields in the schema. Has an accompanying bang method that will raise an exception upon failure.
- *add_multiple!*
  - Takes an array of objects that respond to all the fields in the schema. This provides a more performant way to add multiple documents to the index.

### Searching

Searching is initiated off an `RediSearch::Index` object.
```ruby
main ❯ index = RediSearch::Index.new("user_idx", name: { text: { phonetic: "dm:en" } })
main ❯ index.search("john")
  RediSearch (1.1ms)  FT.SEARCH user_idx `john`
=> [#<RediSearch::Document:0x00007f862e241b78 first: "Gene", last: "Volkman", document_id: "10039">,
#<RediSearch::Document:0x00007f862e2417b8 first: "Jeannie", last: "Ledner", document_id: "9998">]
```
- Simple phrase query - hello AND world
```ruby
index.search("hello").and("world")
```
- Exact phrase query - hello FOLLOWED BY world
```ruby
index.search("hello world")
```
- Union: documents containing either hello OR world
```ruby
index.search("hello").or("world")
```
- Not: documents containing hello but not world
```ruby
index.search("hello").and.not("world")
```

All terms support a few options that can be applied.

- Prefix Queries: match all terms starting with a prefix
```ruby
index.search("hel", prefix: true)
index.search("hello worl", prefix: true)
index.search("hel", prefix: true).and("worl", prefix: true)
index.search("hello").and.not("worl", prefix: true)
```

- Optional terms with higher priority to ones containing more matches
```ruby
index.search("foo").and("bar", optional: true).and("baz", optional: true)
```

- Fuzzy matches are performed based on Levenshtein distance (LD). The maximum Levenshtein distance supported is 3.
```ruby
index.search("zuchini", fuzziness: 1)
```

- Complex intersections and unions
```ruby
# Intersection of unions
index.search(index.search("hello").or("halo")).and(index.search("world").or("werld"))
# Negation of union
index.search("hello").and.not(index.search("world").or("werld"))
# Union inside phrase
index.search("hello").and(index.search("world").or("werld"))
```

### Rails Integration

Integration with Rails is on by default! All you have to do is add the following to the model you want to search:
```ruby
class User < ApplicationRecord
  redi_search schema: {
    first: { text: { phonetic: "dm:en" } },
    last: { text: { phonetic: "dm:en" } }
  }
end
```

This will automatically add `User.search` and `User.reindex` methods. You can also use `User.redi_search_index` to get the `RediSearch::Index` instance. `User.reindex` will first `drop` the index if it exists, create the index with the given schema, and then add all the records to the index.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. You can also start a rails console if you `cd` into `test/dummy`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, execute `bin/publish (major|minor|patch)` which will update the version number in `version.rb`, create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/npezza93/redi_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RediSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npezza93/redi_search/blob/master/CODE_OF_CONDUCT.md).
