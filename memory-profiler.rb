require 'memory_profiler'
report = MemoryProfiler.report do
  # run your code here
end

report.pretty_print
