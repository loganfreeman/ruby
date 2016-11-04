      # Calls a block of code with a modified set of environment variables,
      # restoring them once the code has executed.
      def with_environment(env)
        old_env = {}
        env.each do |var, value|
          old_env[var] = ENV[var.to_s]
          ENV[var.to_s] = value
        end

        yield
      ensure
        old_env.each { |var, value| ENV[var.to_s] = value }
      end
