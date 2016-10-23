module Delayed
  module Plugins
    ##
    # Provides integration with Delayed Job.
    # rubocop:disable Lint/RescueException
    class Airbrake < ::Delayed::Plugin
      callbacks do |lifecycle|
        lifecycle.around(:invoke_job) do |job, *args, &block|
          begin
            # Forward the call to the next callback in the callback chain
            block.call(job, *args)
          rescue Exception => exception
            params = job.as_json.merge(
              component: 'delayed_job',
              action: job.payload_object.class.name
            )

            # If DelayedJob is used through ActiveJob, it contains extra info.
            if job.payload_object.respond_to?(:job_data)
              params[:active_job] = job.payload_object.job_data
            end

            ::Airbrake.notify(exception, params)
            raise exception
          end
        end
      end
    end
    # rubocop:enable Lint/RescueException
  end
end
