require 'test/unit'
require_relative '../lib/two_queues'

class SchedulerTest < Test::Unit::TestCase

  # A kind of acceptance test by running lots of the same to see if the threads
  # behave repeatedly
  # How do you test multithreading without going nuts?..
  def test_500_runs_for_sanity
    actual = (1..500).map do |i|
      ary = []

      # scheduler setup
      scheduler = TwoQueues::Scheduler.new
      scheduler.for_job do |jobs, job|
        job
      end
      scheduler.for_result do |result|
        ary << result
      end
      
      # stuff some jobs in
      (1..5).each do
        scheduler.queue("hello")
      end

      # run
      scheduler.run
      ary
    end

    expected = Array.new(500).fill(["hello","hello","hello","hello","hello"])

    assert expected == actual, "#{expected.first.inspect} != #{actual.first.inspect}"
  end

  def test_adding_jobs_from_within_a_job
    scheduler = TwoQueues::Scheduler.new
    scheduler.for_job do |jobs, job|
      jobs << (job - 1) if job > 1
      job.downto(1).to_a.inject(1){|s,o| s*o }
    end
    ary = []
    scheduler.for_result{|result| ary << result }
    scheduler.queue 5
    scheduler.run
    assert_equal [120, 24, 6, 2, 1], ary
  end

end