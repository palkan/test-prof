# Any Fixture

Fixtures are the great way to increase your test suite performance, but for the large project, they are very hard to maintain.

We propose a more general approach to lazy-generate the _global_ state for your test suite – AnyFixture.

With AnyFixture you can use any block of code for data generation, and it will take care of cleaning it out at the end of the run.

Consider an example:

```ruby
# The best way to use AnyFixture is through RSpec shared contexts
RSpec.shared_context "account", account: true do
  # You should call AnyFixture outside of transaction to re-use the same
  # data between examples
  before(:all) do
    # The provided name ("account") should be unique.
    @account = TestProf::AnyFixture.register(:account) do
      # Do anything here, AnyFixture keeps track of affected DB tables
      # For example, you can use factories here
      FactoryGirl.create(:account)

      # or with Fabrication
      Fabricate(:account)

      # or with plain old AR
      Account.create!(name: "test")
    end
  end

  # Use .register here to track the usage stats (see below)
  let(:account) { TestProf::AnyFixture.register(:account) }

  # Or hard-reload object if there is chance of in-place modification
  let(:account) { Account.find(TestProf::AnyFixture.register(:account).id) }
end

# Then in your tests

# Active this fixture using a tag
describe UsersController, :account do
  # ...
end

# This test also uses the same account record,
# no double-creation
describe PostsController, :account do
  # ...
end
```

See real life [example](http://bit.ly/any-fixture).

## Instructions

### RSpec

In your `spec_helper.rb` (or `rails_helper.rb` if you have one):

```ruby
require "test_prof/recipes/rspec/any_fixture"
```

Now you can use `TestProf::AnyFixture` in your tests.

### Minitest

When using AnyFixture with Minitest you should take care of cleaning the database after each test run by yourself. For example:

```ruby
# test_helper.rb

require "test_prof/any_fixture"

at_exit { TestProf::AnyFixture.clean }
```

## DSL

We provide an optional _syntactic sugar_ (through Refinement) to make easier to define fixtures:

```ruby
require "test_prof/any_fixture/dsl"

# Enable DSL
using TestProf::AnyFixture::DSL

# and then you can use `fixture` method (which is just an alias for `TestProf::AnyFixture.register`)
before(:all) { fixture(:account) }

# You can also use it to fetch the record (instead of storing it in instance variable)
let(:account) { fixture(:account) }
```

## `ActiveRecord#refind`

TestProf also provides an extension to _hard-reload_ ActiveRecord objects:

```ruby
# instead of
let(:account) { Account.find(fixture(:account).id) }

# load refinement
require "test_prof/ext/active_record_refind"

using TestProf::Ext::ActiveRecordRefind

let(:account) { fixture(:account).refind }
```

## Temporary disable fixtures

Some of your tests might rely on _clean database_. Thus running them along with AnyFixture-dependent tests could produce failures.

You can disable (or delete) all created fixture while running a specified example or group using the `:with_clean_fixture` shared context:

```ruby
context "global state", :with_clean_fixture do
  # or include explicitly
  # include_context "any_fixture:clean"

  specify "table is empty or smth like this" do
    # ...
  end
end
```

How does it work? It wraps the example group into a transaction (using [`before_all`](./before_all.md)) and calls `TestProf::AnyFixture.clean` before running the examples.

Thus, this context is a little bit _heavy_. Try to avoid such situations and write specs independent on global state.

## Usage report

`AnyFixture` collects the usage information during the test run and could reports it at the end:

```sh
[TEST PROF INFO] AnyFixture usage stats:

       key    build time  hit count    saved time

      user     00:00.004          4     00:00.017
      post     00:00.002          1     00:00.002

Total time spent: 00:00.006
Total time saved: 00:00.019
Total time wasted: 00:00.000
```

The reporting is off by default, to enable the reporting set `TestProf::AnyFixture.reporting_enabled = true` (or you can invoke it manually through `TestProf::AnyFixture.report_stats`).

You can also enable reporting through `ANYFIXTURE_REPORT=1` env variable.

## Caveats

**UPD:** Since v0.5.0 AnyFixture disable referential integrity (if possible) to prevent the following problem.

`AnyFixture` cleans tables in the reverse order as compared to the order they were populated. That
means when you register a fixture which references a not-yet-registered table, a
foreign-key violation error *might* occur (if any). An example is worth more than 1000
words:

```ruby
class Author < ApplicationRecord
  has_many :articles
end

class Article < ApplicationRecord
  belongs_to :author
end
```

And the shared contexts:

```ruby
RSpec.shared_context "author" do
  before(:all) do
    @author = TestProf::AnyFixture.register(:author) do
      FactoryGirl.create(:account)
    end
  end

  let(:author) { @author }
end

RSpec.shared_context "article" do
  before(:all) do
    # outside of AnyFixture, we don't know about its dependent tables
    author = FactoryGirl.create(:author)

    @article = TestProf::AnyFixture.register(:article) do
      FactoryGirl.create(:article, author: author)
    end
  end

  let(:article) { @article }
end
```

Then in some example:

```ruby
# This one adds only the 'articles' table to the list of affected tables
include_context "article"
# And this one adds the 'authors' table
include_context "author"
```

Now we have the following affected tables list: `['articles', 'authors']`. At the end of the suite, the 'authors' table is cleaned first which leads to a foreign-key violation error.
