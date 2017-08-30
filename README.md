[![Gem Version](https://badge.fury.io/rb/test-prof.svg)](https://rubygems.org/gems/test-prof) [![Build Status](https://travis-ci.org/palkan/test-prof.svg?branch=master)](https://travis-ci.org/palkan/test-prof) [![CircleCI](https://circleci.com/gh/palkan/test-prof.svg?style=svg)](https://circleci.com/gh/palkan/test-prof) [![Code Triagers Badge](https://www.codetriage.com/palkan/test-prof/badges/users.svg)](https://www.codetriage.com/palkan/test-prof)

# Ruby Tests Profiling Toolbox

TestProf is a collection of different tools to analyze your test suite performance.

Why does test suite performance matter? First of all, testing is a part of a developer's feedback loop (see @searls [talk](https://www.youtube.com/watch?v=VD51AkG8EZw)) and, secondly, it is a part of a deployment cycle.

Simply speaking, slow tests waste your time making you less productive.

TestProf toolbox aims to help you identify bottlenecks in your test suite. It contains:

- Plug'n'Play integrations for general Ruby profilers ([`ruby-prof`](https://github.com/ruby-prof), [`stackprof`](https://github.com/tmm1/stackprof))

- Factories usage analyzers and profilers

- ActiveSupport-backed profilers

- Rubocop cops

- etc.

Of course, we have some [solutions](#tips-and-tricks) for common performance issues too, bundled into the gem.

See [Table of Contents](#table-of-contents) for more.

Supported Ruby versions:

- Ruby (MRI) >= 2.2.0

- JRuby >= 9.1.0.0

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Resources

- [TestProf: a good doctor for slow Ruby tests](https://evilmartians.com/chronicles/testprof-a-good-doctor-for-slow-ruby-tests)

- RubyConfBy, 2017, "Run Test Run" talk [[video](https://www.youtube.com/watch?v=q52n4p0wkIs), [slides](https://speakerdeck.com/palkan/rubyconfby-minsk-2017-run-test-run)]

- [Tips to improve speed of your test suite](https://medium.com/appaloosa-store-engineering/tips-to-improve-speed-of-your-test-suite-8418b485205c) by [Benoit Tigeot](https://github.com/benoittgt)

## Installation

Add `test-prof` gem to your application:

```ruby
group :test do
  gem 'test-prof'
end
```

And that's it)

## Table of Contents

Checkout our guides for each specific tool:

- [RubyProf Integration](https://github.com/palkan/test-prof/tree/master/guides/ruby_prof.md)

- [StackProf Integration](https://github.com/palkan/test-prof/tree/master/guides/stack_prof.md)

- [Event Profiler](https://github.com/palkan/test-prof/tree/master/guides/event_prof.md) (e.g. ActiveSupport notifications)

- [Tag Profiler](https://github.com/palkan/test-prof/tree/master/guides/tag_prof.md)

- [Factory Doctor](https://github.com/palkan/test-prof/tree/master/guides/factory_doctor.md)

- [Factory Profiler](https://github.com/palkan/test-prof/tree/master/guides/factory_prof.md)

- [Rubocop Cops](https://github.com/palkan/test-prof/tree/master/guides/rubocop.md)

## Tips and Tricks (or _Recipes_)

We also want to share some small code tricks which can help you to improve your test suite performance and efficiency:

- [`before_all` Hook](https://github.com/palkan/test-prof/tree/master/guides/before_all.md)

- [AnyFixture](https://github.com/palkan/test-prof/tree/master/guides/any_fixture.md)

- [FactoryDefault](https://github.com/palkan/test-prof/tree/master/guides/factory_default.md)

- [RSpec Stamp](https://github.com/palkan/test-prof/tree/master/guides/rspec_stamp.md)

- [Tests Sampling](https://github.com/palkan/test-prof/tree/master/guides/tests_sampling.md)

## Configuration

TestProf global configuration is used by most of the profilers:

```ruby
TestProf.configure do |config|
  # the directory to put artifacts (reports) in ("tmp/test_prof" by default)
  config.output_dir = "tmp/test_prof"

  # use unique filenames for reports (by simply appending current timestamp)
  config.timestamps = true

  # color output
  config.color = true
end
```

## What's next?

Or TODO list:

- Better Minitest integration (PRs welcome!)

- Other data generation library support (e.g [Fabricator](http://fabricationgem.org/)). _Does anyone use something except from FactoryGirl?_

- Improve FactoryDoctor

- Add more Rubocop cops (e.g. `CreateListLimit`)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
