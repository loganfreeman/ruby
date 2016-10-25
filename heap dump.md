Links
---
- [What I Learned About Hunting Memory Leaks in Ruby 2.1](http://blog.skylight.io/hunting-for-leaks-in-ruby/)
- [What’s Inside a Heap Dump?](https://blog.codeship.com/the-definitive-guide-to-ruby-heap-dumps-part-i/)

rbtrace
---

```shell
rbtrace -p PID -e 'Thread.new{require "objspace"; ObjectSpace.trace_object_allocations_start; GC.start(); ObjectSpace.dump_all(output: File.open("heap.json", "w"))}.join'  
```

```ruby
system("rbtrace -p #{Process.pid} -e 'load \"#{Rails.root}/script/heap_dump.rb\"'").  
```

From Dump to Data
---
```shell
gem install heapy
```
we need generate some objects and dump them to disk
```ruby
require 'objspace'

ObjectSpace.trace_object_allocations_start

count = (ARGV.first || 5_000 ).to_i

ARRAY = []
count.times do |x|
  a = "#{x}_foo"
  ARRAY << a
end

file_name = "/tmp/#{Time.now.to_f}-heap.dump"

file = File.open(file_name, 'w')
ObjectSpace.dump_all(output: file)
file.close

puts "heapy read #{file_name}"
```
