require 'test/unit'
require 'two_queues'

class SchedulerTest < Test::Unit::TestCase

  # A kind of acceptance test by running lots of the same to see if the threads
  # behave repeatedly
  # How do you test multithreading without going nuts?..
  def test_500_runs_for_sanity
    actual = (1..500).map do |i|
      ary = []

      # scheduler setup
      scheduler = TwoQueues::Scheduler.new
      scheduler.for_job do |job|
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

    assert_equal expected, actual
  end

end