rbtrace -p PID -e 'Thread.new{require "objspace"; ObjectSpace.trace_object_allocations_start; GC.start(); ObjectSpace.dump_all(output: File.open("heap.json", "w"))}.join'  
