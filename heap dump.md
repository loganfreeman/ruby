Links
---
- [What I Learned About Hunting Memory Leaks in Ruby 2.1](http://blog.skylight.io/hunting-for-leaks-in-ruby/)

```shell
rbtrace -p PID -e 'Thread.new{require "objspace"; ObjectSpace.trace_object_allocations_start; GC.start(); ObjectSpace.dump_all(output: File.open("heap.json", "w"))}.join'  
```

```ruby
system("rbtrace -p #{Process.pid} -e 'load \"#{Rails.root}/script/heap_dump.rb\"'").  
```
