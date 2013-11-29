require 'thread'

module TwoQueues
  class Scheduler

    attr_accessor :jobs

    #
    # options - :jobs        - give it a pre-exisiting jobs queue
    #           :results     - give it a pre-exisiting results queue
    #           :num_workers - the number of threads to start
    #
    def initialize(opts={})
      @opts = opts
      @jobs = @opts.delete(:jobs) || Queue.new
      @results = @opts.delete(:results) || Queue.new
      @num_workers = @opts[:num_workers] || 2
    end

    def queue(job)
      @jobs.push(job)
    end

    def for_job(&block)
      @for_job = block
    end

    def for_result(&block)
      @for_result = block
    end

    #
    # Creates and starts workers
    #
    def run
      # stop if we don't what to do for jobs or results
      raise ArgumentError, "The for_job block must be set" unless @for_job
      raise ArgumentError, "The for_result block must be set" unless @for_result

      # create the workers
      @workers = Array.new(@num_workers).map do |worker|
        Thread.new(@jobs, @results){|jobs, results|
          loop do
            results << @for_job.call(jobs, jobs.pop)
          end
        }
      end

      # loop main thread until complete
      loop do
        # wait and pass result into for_result block
        @for_result.call(@results.pop)

        if @results.empty? && @jobs.empty?
          until @jobs.num_waiting == @workers.size
            Thread.pass
          end
          @workers.each(&:kill)
          break
        end
      end


    end

  end
end