<p align="center">
  <a href="https://github.com/npezza93/redi_search">
    <img src="https://raw.githubusercontent.com/npezza93/redi_search/master/.github/logo.svg?sanitize=true" width="350">
  </a>
</p>

# RediSearch

[![Build Status](https://travis-ci.com/npezza93/redi_search.svg?branch=master)](https://travis-ci.com/npezza93/redi_search)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c6437acac5684de2549d/test_coverage)](https://codeclimate.com/github/npezza93/redi_search/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/c6437acac5684de2549d/maintainability)](https://codeclimate.com/github/npezza93/redi_search/maintainability)

A simple, but powerful Ruby wrapper around RediSearch, a search engine on top of
Redis.

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

And then:
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

Most actions taken revolve around indices so we will start there.

### Index

```ruby
RediSearch::Index.new(name_of_index, schema)
```
`name_of_index` is a string or symbol identifying the index and the schema is a
hash, with field names as the keys, defining fields and options in an index.
Each field can be one of four types: geo, numeric, tag, or text. The supported
options for each type are as follows:

##### Text field
With no options: `{ name: :text }`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>weight</b> (default: 1.0)
      <ul>
        <li>Declares the importance of this field when calculating result accuracy. This is a multiplication factor.</li>
        <li>Ex: <code>{ name: { text: { weight: 2 } } }</code></li>
      </ul>
    </li>
    <li>
      <b>phonetic</b>
      <ul>
        <li>Will perform phonetic matching on field in searches by default. The obligatory {matcher} argument specifies the phonetic algorithm and language used. The following matchers are supported:
          <ul>
            <li>dm:en - Double Metaphone for English</li>
            <li>dm:fr - Double Metaphone for French</li>
            <li>dm:pt - Double Metaphone for Portuguese</li>
            <li>dm:es - Double Metaphone for Spanish</li>
          </ul>
        </li>
        <li>
          Ex: <code>{ name: { text: { phonetic: 'dm:en' } } }</code>
        </li>
      </ul>
    </li>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>{ name: { text: { sortable: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>{ name: { text: { no_index: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>no_stem</b> (default: false)
      <ul>
        <li>Disable stemming when indexing its values. This may be ideal for things like proper names.</li>
        <li>Ex: <code>{ name: { text: { no_stem: true } } }</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Numeric field
With no options: `{ name: :numeric }`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>{ id: { numeric: { sortable: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>{ id: { numeric: { no_index: true } } }</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Tag field
With no options: `{ tag: :tag }`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>{ tag: { tag: { sortable: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>{ tag: { tag: { no_index: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>separator</b> (default: ",")
      <ul>
        <li>Indicates how the text contained in the field is to be split into individual tags. The default is ,. The value must be a single character.</li>
        <li>Ex: <code>{ tag: { tag: { separator: ',' } } }</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Geo field
With no options: `{ place: :geo }`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>{ place: { geo: { sortable: true } } }</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>{ place: { geo: { no_index: true } } }</code></li>
      </ul>
    </li>
  </ul>
</details>

#### Commands

##### create
  Creates the index in the Redis instance, returns a boolean. Has an accompanying bang method that will raise an exception upon failure.
##### drop
  Drops the index from the Redis instance, returns a boolean. Has an accompanying bang method that will raise an exception upon failure.
##### exist?
  Returns a boolean signifying index existence.
##### info
  Returns an object with all the information about the index
##### fields
  Returns an array of the field names in the index
##### add(record, score = 1.0)
  Takes an object the responds to all the fields in the index and a score (a value between 0.0 and 1.0). Has an accompanying bang method that will raise an exception upon failure.
##### add_multiple!(records)
  Takes an array of objects that respond to all the fields in the schema. This provides a more performant way to add multiple documents to the index.
##### del(record, delete_document: false)
  Takes a record and remove it from the index. `delete_document` signifies whether the document should be completely removed from the Redis instance.

### Searching

Searching is initiated off an `RediSearch::Index` object and has a powerful query language.
```ruby
main ❯ index = RediSearch::Index.new("user_idx", name: { text: { phonetic: "dm:en" } })
main ❯ index.search("john")
  RediSearch (1.1ms)  FT.SEARCH user_idx `john`
=> [#<RediSearch::Document:0x00007f862e241b78 first: "Gene", last: "Volkman", document_id: "10039">,
#<RediSearch::Document:0x00007f862e2417b8 first: "Jeannie", last: "Ledner", document_id: "9998">]
```
Simple phrase query - hello AND world
```ruby
index.search("hello").and("world")
```
Exact phrase query - hello FOLLOWED BY world
```ruby
index.search("hello world")
```
Union: documents containing either hello OR world
```ruby
index.search("hello").or("world")
```
Not: documents containing hello but not world
```ruby
index.search("hello").and.not("world")
```

All terms support a few options that can be applied.

Prefix Queries: match all terms starting with a prefix
```ruby
index.search("hel", prefix: true)
index.search("hello worl", prefix: true)
index.search("hel", prefix: true).and("worl", prefix: true)
index.search("hello").and.not("worl", prefix: true)
```

Optional terms with higher priority to ones containing more matches
```ruby
index.search("foo").and("bar", optional: true).and("baz", optional: true)
```

Fuzzy matches are performed based on Levenshtein distance (LD). The maximum Levenshtein distance supported is 3.
```ruby
index.search("zuchini", fuzziness: 1)
```

Complex intersections and unions
```ruby
# Intersection of unions
index.search(index.search("hello").or("halo")).and(index.search("world").or("werld"))
# Negation of union
index.search("hello").and.not(index.search("world").or("werld"))
# Union inside phrase
index.search("hello").and(index.search("world").or("werld"))
```

##### Query level options
- **slop(level)**
  - We allow a maximum of N intervening number of unmatched offsets between phrase terms. (i.e the slop for exact phrases is 0)
- **in_order**
  - Usually used in conjunction with SLOP, we make sure the query terms appear in the same order in the document as in the query, regardless of the offsets between them.
- **no_content**
  - Only return the document ids and not the content. This is useful if RediSearch is only an index on an external document collection.
- **language**
  - Stemmer to use for the supplied language during search for query expansion. If querying documents in Chinese, this should be set to chinese in order to properly tokenize the query terms. Defaults to English. If an unsupported language is sent, the command returns an error.
- **sort_by(field, order: :asc)**
  - If the supplied field is a sortable field, the results are ordered by the value of this field. This applies to both text and numeric fields. Available order is `:asc` or `:desc`
- **limit(num, offset = 0)**
  - Limit the results to the specified num at the offset. The default limit is 10. Note that you can use `limit(0)` to count the number of documents in the resultset without actually returning them.
- **highlight(fields: [], tags: {})**
  - Use this option to format occurrences of matched text. `fields` are an array of fields to be highlighted and `tags` should contain an `open` and `close` key that signifies the opening and closing tags when highlighting.

### Rails Integration

Integration with Rails is on by default! All you have to do is add the following to your model:
```ruby
class User < ApplicationRecord
  redi_search schema: {
    first: { text: { phonetic: "dm:en" } },
    last: { text: { phonetic: "dm:en" } }
  }
end
```

This will automatically add `User.search` and `User.reindex` methods. You can also use `User.redi_search_index` to get the `RediSearch::Index` instance. `User.reindex` will first `drop` the index if it exists, `create` the index with the given schema, and then `add` all the records to the index.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. You can also start a rails console if you `cd` into `test/dummy`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, execute `bin/publish (major|minor|patch)` which will update the version number in `version.rb`, create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/npezza93/redi_search). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RediSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npezza93/redi_search/blob/master/CODE_OF_CONDUCT.md).
