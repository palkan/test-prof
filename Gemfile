source 'https://rubygems.org'

# Specify your gem's dependencies in test-prof.gemspec
gemspec

gem "sqlite3"
gem "activerecord", "~> 5.0"

gem "factory_bot", "~> 4.8.0"
gem "fabrication"

gem "sidekiq", "~> 5.1"
gem "timecop", "~> 0.9.1"

gem "pry-byebug"

local_gemfile = "Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
