two_queues
==========

A multi-threaded job scheduler. Two queues. Jobs in one queue and results out on the other.

### Example

Calculate the first five factorials.. in a really over the top way.

```
scheduler = TwoQueues::Scheduler.new

scheduler.for_job do |jobs, job|
  # put the number below on the jobs queue
  jobs << (job - 1) if job > 1
  # return the current factorial
  job.downto(1).to_a.inject(1){|s,o| s*o }
end

ary = []

scheduler.for_result{|result| ary << result }

scheduler.queue 5

scheduler.run

puts ary #=> [120, 24, 6, 2, 1]
```
