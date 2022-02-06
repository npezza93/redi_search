<p align="center">
  <a href="https://github.com/npezza93/redi_search">
    <img src="https://raw.githubusercontent.com/npezza93/redi_search/main/.github/logo.svg?sanitize=true" width="350">
  </a>
</p>

# RediSearch

A simple, but powerful, Ruby wrapper around RediSearch, a search engine on top of
Redis.

## Installation

Firstly, Redis and RediSearch need to be installed.

You can download Redis from https://redis.io/download, and check out
installation instructions
[here](https://github.com/antirez/redis#installing-redis). Alternatively, on
macOS or Linux you can install via Homebrew.

To install RediSearch check out,
[https://oss.redislabs.com/redisearch/Quick_Start.html](https://oss.redislabs.com/redisearch/Quick_Start.html).
Once you have RediSearch built, if you are not using Docker, you can update your
redis.conf file to always load the RediSearch module with
`loadmodule /path/to/redisearch.so`. (On macOS the redis.conf file can be found
at `/usr/local/etc/redis.conf`)

After Redis and RediSearch are up and running, add the following line to your
Gemfile:

```ruby
gem 'redi_search'
```

And then:
```bash
❯ bundle
````

Or install it yourself:
```bash
❯ gem install redi_search
```

and require it:
```ruby
require 'redi_search'
```

Once the gem is installed and required you'll need to configure it with your
Redis configuration. If you're on Rails, this should go in an initializer
(`config/initializers/redi_search.rb`).

```ruby
RediSearch.configure do |config|
  config.redis_config = {
    host: "127.0.0.1",
    port: "6379"
  }
end
```

## Table of Contents
   - [Preface](#preface)
   - [Schema](#schema)
   - [Document](#document)
   - [Index](#index)
   - [Searching](#searching)
   - [Spellcheck](#spellcheck)
   - [Rails Integration](#rails-integration)


## Preface
RediSearch revolves around a search index, so lets start with
defining what a search index is. According to [Swiftype](https://swiftype.com):
> A search index is a body of structured data that a search engine refers to
> when looking for results that are relevant to a specific query. Indexes are a
> critical piece of any search system, since they must be tailored to the
> specific information retrieval method of the search engine’s algorithm. In
> this manner, the algorithm and the index are inextricably linked to one
> another. Index can also be used as a verb (indexing), referring to the process
> of collecting unstructured website data in a structured format that is
> tailored for the search engine algorithm.
>
> One way to think about indices is to consider the following analogy between a
> search infrastructure and an office filing system. Imagine you hand an intern
> a stack of thousands of pieces of paper (documents) and tell them to organize
> these pieces of paper in a filing cabinet (index) to help the company find
> information more efficiently. The intern will first have to sort through the
> papers and get a sense of all the information contained within them, then they
> will have to decide on a system for arranging them in the filing cabinet, then
> finally they’ll need to decide what is the most effective manner for searching
> through and selecting from the files once they are in the cabinet. In this
> example, the process of organizing and filing the papers corresponds to the
> process of indexing website content, and the method for searching across these
> organized files and finding those that are most relevant corresponds to the
> search algorithm.


## Schema

This defines the fields and the properties of those fields in the index. A
schema is a simple DSL. Each field can be one of four types: geo, numeric, tag,
or text and can have many options. A simple example of a schema is:
```ruby
RediSearch::Schema.new do
  text_field :first_name
  text_field :last_name
end
```

The supported options for each type are as follows:

##### Text field
With no options: `text_field :name`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>weight</b> (default: 1.0)
      <ul>
        <li>Declares the importance of this field when calculating result accuracy. This is a multiplication factor.</li>
        <li>Ex: <code>text_field :name, weight: 2</code></li>
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
          Ex: <code>text_field :name, phonetic: 'dm:en'</code>
        </li>
      </ul>
    </li>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>text_field :name, sortable: true</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>text_field :name, no_index: true</code></li>
      </ul>
    </li>
    <li>
      <b>no_stem</b> (default: false)
      <ul>
        <li>Disable stemming when indexing its values. This may be ideal for things like proper names.</li>
        <li>Ex: <code>text_feidl :name, no_stem: true</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Numeric field
With no options: `numeric_field :price`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>numeric_field :id, sortable: true</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>numeric_field :id, no_index: true</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Tag field
With no options: `tag_field :tag`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>tag_field :tag, sortable: true</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>tag_field :tag, no_index: true</code></li>
      </ul>
    </li>
    <li>
      <b>separator</b> (default: ",")
      <ul>
        <li>Indicates how the text contained in the field is to be split into individual tags. The default is ,. The value must be a single character.</li>
        <li>Ex: <code>tag_field :tag, separator: ','</code></li>
      </ul>
    </li>
  </ul>
</details>

##### Geo field
With no options: `geo_field :place`

<details>
  <summary>Options</summary>
  <ul>
    <li>
      <b>sortable</b> (default: false)
      <ul>
        <li>Allows the user to later sort the results by the value of this field (this adds memory overhead so do not declare it on large text fields).</li>
        <li>Ex: <code>geo_field :place, sortable: true</code></li>
      </ul>
    </li>
    <li>
      <b>no_index</b> (default: false)
      <ul>
        <li>Field will not be indexed. This is useful in conjunction with <code>sortable</code>, to create fields whose update using PARTIAL will not cause full reindexing of the document. If a field has <code>no_index</code> and doesn't have <code>sortable</code>, it will just be ignored by the index.</li>
        <li>Ex: <code>geo_field :place, no_index: true</code></li>
      </ul>
    </li>
  </ul>
</details>

## Document

A `Document` is the Ruby representation of a Redis hash.

You can fetch a `Document` using `.get` class methods.
- `get(index, document_id)` fetches a single `Document` in an `Index` for a
given `document_id`.

You can also make a `Document` instance using the
`.for_object(index, record, only: [])` class method. It takes
an `Index` instance and a Ruby object. That object must respond to all the
fields specified in the `Index`'s `Schema`. `only` accepts an array of fields
from the schema and limits the fields that are passed to the `Document`.

Once you have an instance of a `Document`, it responds to all the fields
specified in the `Index`'s `Schema` as methods and `document_id`. `document_id`
is automatically prepended with the `Index`'s names unless it already is to
ensure uniqueness. We prepend the `Index` name because if you have two
`Document`s with the same id in different `Index`s we don't want the `Document`s
to override each other. There is also a `#document_id_without_index` method
which removes the prepended index name.

Finally there is a `#del` method that will remove the `Document` from the
`Index`.

## Index

To initialize an `Index`, pass the name of the `Index` as a string or symbol
and the `Schema` block.

```ruby
RediSearch::Index.new(name_of_index) do
  text_field :foobar
end
```

#### Available Commands

- `create`
  - Creates the index in the Redis instance, returns a boolean. Has an
    accompanying bang method that will raise an exception upon failure. Will
    return `false` if the index already exists. Accepts a few options:
      - `max_text_fields: #{true || false}`
        - For efficiency, RediSearch encodes indexes differently if they are
          created with less than 32 text fields. This option forces RediSearch
          to encode indexes as if there were more than 32 text fields, which
          allows you to add additional fields (beyond 32) using `add_field`.
      - `no_offsets: #{true || false}`
        - If set, we do not store term offsets for documents (saves memory, does
          not allow exact searches or highlighting). Implies `no_highlight`.
      - `temporary: #{seconds}`
        - Create a lightweight temporary index which will expire after `seconds`
          seconds of inactivity. The internal idle timer is reset whenever the
          index is searched or added to. Because such indexes are lightweight,
          you can create thousands of such indexes without negative performance
          implications.
      - `no_highlight: #{true || false}`
        - Conserves storage space and memory by disabling highlighting support.
          If set, we do not store corresponding byte offsets for term positions.
          `no_highlight` is also implied by `no_offsets`.
      - `no_fields: #{true || false}`
        - If set, we do not store field bits for each term. Saves memory, does
          not allow filtering by specific fields.
      - `no_frequencies: #{true || false}`
        - If set, we avoid saving the term frequencies in the index. This saves
          memory but does not allow sorting based on the frequencies of a given
          term within the document.
- `drop(keep_docs: false)`
  - Drops the `Index` from the Redis instance, returns a boolean. Has an
    accompanying bang method that will raise an exception upon failure. Will
    return `false` if the `Index` has already been dropped. Takes an option
    keyword arg, `keep_docs`, that will by default remove all the document
    hashes in Redis.
- `exist?`
  - Returns a boolean signifying `Index` existence.
- `info`
  - Returns a struct object with all the information about the `Index`.
- `fields`
  - Returns an array of the field names in the `Index`.
- `add(document)`
  - Takes a `Document` object. Has an
    accompanying bang method that will raise an exception upon failure.
- `add_multiple(documents)`
  - Takes an array of `Document` objects. This provides a more performant way to
    add multiple documents to the `Index`. Accepts the same options as `add`.
- `del(document)`
  - Removes a `Document` from the `Index`.
- `document_count`
  - Returns the number of `Document`s in the `Index`
- `add_field(name, type, **options, &block)`
  - Adds a new field to the `Index`.
  - The block and options are optional.
  - Ex: `index.add_field(:first_name, :text, phonetic: "dm:en")`
- `reindex(documents, recreate: false)`
   - If `recreate` is `true` the `Index` will be dropped and recreated


## Searching

Searching is initiated off a `RediSearch::Index` instance with clauses that can
be chained together. When searching, an array of `Document`s is returned
which has public reader methods for all the schema fields.

```ruby
main ❯ index = RediSearch::Index.new("user_idx") { text_field :name, phonetic: "dm:en" }
main ❯ index.add RediSearch::Document.for_object(index, User.new("10039", "Gene", "Volkman"))
main ❯ index.add RediSearch::Document.for_object(index, User.new("9998", "Jeannie", "Ledner"))
main ❯ index.search("john")
  RediSearch (1.1ms)  FT.SEARCH user_idx `john`
=> [#<RediSearch::Document:0x00007f862e241b78 first: "Gene", last: "Volkman", document_id: "10039">,
#<RediSearch::Document:0x00007f862e2417b8 first: "Jeannie", last: "Ledner", document_id: "9998">]
```
**Simple phrase query** - `hello AND world`
```ruby
index.search("hello").and("world")
```
**Exact phrase query** - `hello FOLLOWED BY world`
```ruby
index.search("hello world")
```
**Union query** - `hello OR world`
```ruby
index.search("hello").or("world")
```
**Negation query** - `hello AND NOT world`
```ruby
index.search("hello").and.not("world")
```

Complex intersections and unions:
```ruby
# Intersection of unions
index.search(index.search("hello").or("halo")).and(index.search("world").or("werld"))
# Negation of union
index.search("hello").and.not(index.search("world").or("werld"))
# Union inside phrase
index.search("hello").and(index.search("world").or("werld"))
```

All terms support a few options that can be applied.

**Prefix terms**: match all terms starting with a prefix.
(Akin to `like term%` in SQL)
```ruby
index.search("hel", prefix: true)
index.search("hello worl", prefix: true)
index.search("hel", prefix: true).and("worl", prefix: true)
index.search("hello").and.not("worl", prefix: true)
```

**Optional terms**: documents containing the optional terms will rank higher
than those without
```ruby
index.search("foo").and("bar", optional: true).and("baz", optional: true)
```

**Fuzzy terms**: matches are performed based on Levenshtein distance (LD). The
maximum Levenshtein distance supported is 3.
```ruby
index.search("zuchini", fuzziness: 1)
```

Search terms can also be scoped to specific fields using a `where` clause:
```ruby
# Simple field specific query
index.search.where(name: "john")
# Using where with options
index.search.where(first: "jon", fuzziness: 1)
# Using where with more complex query
index.search.where(first: index.search("bill").or("bob"))
```

Searching for numeric fields takes a range:
```ruby
index.search.where(number: 0..100)
# Searching to infinity
index.search.where(number: 0..Float::INFINITY)
index.search.where(number: -Float::INFINITY..0)
```

##### Query level clauses
- `slop(level)`
  - We allow a maximum of N intervening number of unmatched offsets between
  phrase terms. (i.e the slop for exact phrases is 0)
- `in_order`
  - Usually used in conjunction with `slop`. We make sure the query terms appear
    in the same order in the `Document` as in the query, regardless of the
    offsets between them.
- `no_content`
  - Only return the `Document` ids and not the content. This is useful if
    RediSearch is being used on a Rails model where the `Document` attributes
    don't matter and it's being converted into `ActiveRecord` objects.
- `language(language)`
  - Stemmer to use for the supplied language during search for query expansion.
    If querying `Document`s in Chinese, this should be set to chinese in order to
    properly tokenize the query terms. If an unsupported language is sent, the
    command returns an error.
- `sort_by(field, order: :asc)`
  - If the supplied field is a sortable field, the results are ordered by the
    value of this field. This applies to both text and numeric fields. Available
    orders are `:asc` or `:desc`
- `limit(num, offset = 0)`
  - Limit the results to the specified `num` at the `offset`. The default limit
    is set to `10`.
- `count`
  - Returns the number of `Document`s found in the search query
- `highlight(fields: [], opening_tag: "<b>", closing_tag: "</b>")`
  - Use this option to format occurrences of matched text. `fields` are an
    array of fields to be highlighted.
- `verbatim`
  - Do not try to use stemming for query expansion but search the query terms
    verbatim.
- `no_stop_words`
  - Do not filter stopwords from the query.
- `with_scores`
  - Include the relative internal score of each `Document`. This can be used to
    merge results from multiple instances. This will add a `score` method to the
    returned `Document` instances.
- `return(*fields)`
  - Limit which fields from the `Document` are returned.
- `explain`
  - Returns the execution plan for a complex query. In the returned response,
    a + on a term is an indication of stemming.


## Spellcheck

Spellchecking is initiated off a `RediSearch::Index` instance and provides
suggestions for misspelled search terms. It takes an optional `distance`
argument which is the maximal Levenshtein distance for spelling suggestions. It
returns an array where each element contains suggestions for each search term
and a normalized score based on its occurrences in the index.

```ruby
main ❯ index = RediSearch::Index.new("user_idx") { text_field :name, phonetic: "dm:en" }
main ❯ index.spellcheck("jimy")
  RediSearch (1.1ms)  FT.SPELLCHECK user_idx jimy DISTANCE 1
  => [#<RediSearch::Spellcheck::Result:0x00007f805591c670
    term: "jimy",
    suggestions:
     [#<struct RediSearch::Spellcheck::Suggestion score=0.0006849315068493151, suggestion="jimmy">,
      #<struct RediSearch::Spellcheck::Suggestion score=0.00019569471624266145, suggestion="jim">]>]
main ❯ index.spellcheck("jimy", distance: 2).first.suggestions
  RediSearch (0.5ms)  FT.SPELLCHECK user_idx jimy DISTANCE 2
=> [#<struct RediSearch::Spellcheck::Suggestion score=0.0006849315068493151, suggestion="jimmy">,
 #<struct RediSearch::Spellcheck::Suggestion score=0.00019569471624266145, suggestion="jim">]
```


## Rails Integration

Integration with Rails is super easy! Call `redi_search` with the `schema`
keyword argument from inside your model. Ex:

```ruby
class User < ApplicationRecord
  redi_search do
    text_field :first, phonetic: "dm:en"
    text_field :last, phonetic: "dm:en"
  end
end
```

This will automatically add `User.search` and `User.spellcheck`
methods which behave the same as if you called them on an `Index` instance.

`User.reindex(recreate: false, only: [])` is also added and behaves
similarly to `RediSearch::Index#reindex`. Some of the differences include:
  - `Document`s do not need to be passed as the first parameter. The `search_import`
    scope is automatically called and all the records are converted
    to `Document`s.
  - Accepts an optional `only` parameter where you can specify a limited number
    of fields to update. Useful if you alter the schema and only need to index a
    particular field.


While defining the schema you can optionally pass it a block. If no block is
passed the `name` will called on the model to get the value. If a block is
passed the value for the field is obtained through calling the block.

```ruby
class User < ApplicationRecord
  redi_search do
    text_field :name do
      "#{first_name} #{last_name}"
    end
  end
end
```

You can override the `search_import` scope on the model to eager load
relationships when indexing or it can be used to limit the records to index.

```ruby
class User < ApplicationRecord
  scope :search_import, -> { includes(:posts) }
end
```

When searching, by default a collection of `Document`s is returned. Calling
`#results` on the search query will execute the search, and then look up all the
found records in the database and return an ActiveRecord relation.

The default `Index` name for model `Index`s is
`#{model_name.plural}_#{RediSearch.env}`. The `redi_search` method takes an
optional `index_prefix` argument which gets prepended to the index name:

```ruby
class User < ApplicationRecord
  redi_search index_prefix: 'prefix' do
    text_field :first, phonetic: "dm:en"
    text_field :last, phonetic: "dm:en"
  end
end

User.search_index.name
# => prefix_users_development
```

When integrating RediSearch into a model, records will automatically be indexed
after creating and updating and will be removed from the `Index` upon
destruction.

There are a few more convenience methods that are publicly available:
- `search_document`
  - Returns the record as a `RediSearch::Document` instance
- `remove_from_index`
  - Removes the record from the `Index`
- `add_to_index`
  - Adds the record to the `Index`
- `search_index`
  - Returns the `RediSearch::Index` instance


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the both unit and integration tests. To run them individually
you can run `rake test:unit` or `rake test:integration`. You can also run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, execute `bin/publish (major|minor|patch)` which will
update the version number in `version.rb`, create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org) and GitHub.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/npezza93/redi_search). This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RediSearch project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/npezza93/redi_search/blob/main/CODE_OF_CONDUCT.md).
