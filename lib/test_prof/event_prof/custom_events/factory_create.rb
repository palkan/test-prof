# frozen_string_literal: true

require "test_prof/ext/string_strip_heredoc"

using TestProf::StringStripHeredoc

module TestProf::EventProf::CustomEvents
  module FactoryCreate # :nodoc: all
    module RunnerPatch
      def run(strategy = @strategy)
        return super unless strategy == :create
        FactoryCreate.track(@name) do
          super
        end
      end
    end

    class << self
      def setup!
        @depth = 0
        FactoryGirl::FactoryRunner.prepend RunnerPatch
      end

      def track(factory)
        @depth += 1
        res = nil
        begin
          res =
            if @depth == 1
              ActiveSupport::Notifications.instrument(
                'factory.create',
                name: factory
              ) { yield }
            else
              yield
            end
        ensure
          @depth -= 1
        end
        res
      end
    end
  end
end

TestProf.activate('EVENT_PROF', 'factory.create') do
  if TestProf.require(
    'factory_girl',
    <<-MSG.strip_heredoc
      Failed to load FactoryGirl.

      Make sure that "factory_girl" gem is in your Gemfile.
    MSG
  )
    TestProf::EventProf::CustomEvents::FactoryCreate.setup!
  end
end
