require 'objspace'

# enable tracing for file/line/generation data in dumps
ObjectSpace.trace_object_allocations_start

# dump single object as json string
ObjectSpace.dump("abc".freeze) #=> "{...}"

# dump out all live objects to a json file
GC.start
ObjectSpace.dump_all(output: File.open('heap.json','w'))
