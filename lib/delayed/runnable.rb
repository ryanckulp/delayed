module Delayed
  module Runnable
    def start
      trap('TERM') { quit! }
      trap('INT') { quit! }

      say "Starting #{self.class.name}"

      loop do
        run!
        interruptable_sleep(self.class.sleep_delay)
        break if stop?
      end
    ensure
      on_exit!
    end

    private

    def on_exit!; end

    def interruptable_sleep(seconds)
      IO.select([pipe[0]], nil, nil, seconds)
    end

    def stop
      pipe[1].close
    end

    def stop?
      pipe[1].closed?
    end

    def quit!
      Thread.new { say 'Exiting...' }.tap do |t|
        stop
        t.join
      end
    end

    def pipe
      @pipe ||= IO.pipe
    end
  end
end
