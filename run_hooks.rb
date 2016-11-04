    def run_hooks
      if @hooks.any?(&:enabled?)
        @printer.start_run

        # Sort so hooks requiring fewer processors get queued first. This
        # ensures we make better use of our available processors
        @hooks_left = @hooks.sort_by { |hook| processors_for_hook(hook) }
        @threads = Array.new(@config.concurrency) { Thread.new(&method(:consume)) }

        begin
          InterruptHandler.disable_until_finished_or_interrupted do
            @threads.each(&:join)
          end
        rescue Interrupt
          @printer.interrupt_triggered
          # We received an interrupt on the main thread, so alert the
          # remaining workers that an exception occurred
          @interrupted = true
          @threads.each { |thread| thread.raise Interrupt }
        end

        print_results

        !(@failed || @interrupted)
      else
        @printer.nothing_to_run
        true # Run was successful
      end
    end

    def consume
      loop do
        hook = @lock.synchronize { @hooks_left.pop }
        break unless hook
        run_hook(hook)
      end
    end
