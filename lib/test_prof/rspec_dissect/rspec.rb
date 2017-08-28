# frozen_string_literal: true

require "test_prof/ext/float_duration"
require "test_prof/ext/string_truncate"
require "test_prof/utils/sized_ordered_set"

module TestProf
  module RSpecDissect
    class Listener # :nodoc:
      include Logging
      using FloatDuration
      using StringTruncate

      NOTIFICATIONS = %i[
        example_finished
        example_group_finished
      ].freeze

      def initialize
        @before_results = Utils::SizedOrderedSet.new(
          top_count, sort_by: :before
        )
        @memo_results = Utils::SizedOrderedSet.new(
          top_count, sort_by: :memo
        )
        @examples_count = 0
        @examples_time = 0.0
        @total_examples_time = 0.0
      end

      def example_finished(notification)
        @examples_count += 1
        @examples_time += notification.example.execution_result.run_time
      end

      def example_group_finished(notification)
        return unless notification.group.top_level?

        data = {}
        data[:total] = @examples_time
        data[:count] = @examples_count
        data[:before] = RSpecDissect.before_time
        data[:memo] = RSpecDissect.memo_time
        data[:desc] = notification.group.top_level_description
        data[:loc] = notification.group.metadata[:location]

        @before_results << data
        @memo_results << data

        @total_examples_time += @examples_time
        @examples_count = 0
        @examples_time = 0.0

        RSpecDissect.reset!
      end

      def print
        msgs = []

        msgs <<
          <<~MSG
            RSpecDissect report

            Total time: #{@total_examples_time.duration}
            Total `before(:each)` time: #{RSpecDissect.total_before_time.duration}
            Total `let` time: #{RSpecDissect.total_memo_time.duration}

          MSG

        msgs <<
          <<~MSG
            Top #{top_count} slowest suites (by `before(:each)` time):

          MSG

        @before_results.each do |group|
          msgs <<
            <<~GROUP
              #{group[:desc].truncate} (#{group[:loc]}) – #{group[:before].duration} of #{group[:total].duration} (#{group[:count]})
            GROUP
        end

        msgs <<
          <<~MSG
            Top #{top_count} slowest suites (by `let` time):

          MSG

        @memo_results.each do |group|
          msgs <<
            <<~GROUP
              #{group[:desc].truncate} (#{group[:loc]}) – #{group[:memo].duration} of #{group[:total].duration} (#{group[:count]})
            GROUP
        end

        log :info, msgs.join
      end

      private

      def top_count
        RSpecDissect.config.top_count
      end
    end
  end
end

# Register RSpecDissect listener
TestProf.activate('RD') do
  RSpec.configure do |config|
    listener = TestProf::RSpecDissect::Listener.new

    config.before(:suite) do
      config.reporter.register_listener(
        listener, *TestProf::RSpecDissect::Listener::NOTIFICATIONS
      )
    end

    config.after(:suite) { listener.print }
  end
end
