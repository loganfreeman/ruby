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

    def wait_for_slot(hook)
      @lock.synchronize do
        slots_needed = processors_for_hook(hook)

        loop do
          if @slots_available >= slots_needed
            @slots_available -= slots_needed

            # Give another thread a chance since there are still slots available
            @resource.signal if @slots_available > 0
            break
          elsif @slots_available > 0
            # It's possible that another hook that requires fewer slots can be
            # served, so give another a chance
            @resource.signal

            # Wait for a signal from another thread to try again
            @resource.wait(@lock)
          end
        end
      end
    end

    def release_slot(hook)
      @lock.synchronize do
        slots_released = processors_for_hook(hook)
        @slots_available += slots_released

        if @hooks_left.any?
          # Signal once. `wait_for_slot` will perform additional signals if
          # there are still slots available. This prevents us from sending out
          # useless signals
          @resource.signal
        end
      end
    end
