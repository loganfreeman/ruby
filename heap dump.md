Links
---
- [What I Learned About Hunting Memory Leaks in Ruby 2.1](http://blog.skylight.io/hunting-for-leaks-in-ruby/)
- [What’s Inside a Heap Dump?](https://blog.codeship.com/the-definitive-guide-to-ruby-heap-dumps-part-i/)
- [heapy](https://github.com/schneems/heapy)
- [Ruby 2.1: objspace.so](http://tmm1.net/ruby21-objspace/)
- [Debugging memory leaks in Ruby](https://samsaffron.com/archive/2015/03/31/debugging-memory-leaks-in-ruby)


objspace.so
---
```ruby
require 'objspace'

# enable tracing for file/line/generation data in dumps
ObjectSpace.trace_object_allocations_start

ObjectSpace.dump_all(output: File.open('heap.json','w'))
```

a simple ruby/shell script to see which gems/libraries create the most long-lived objects of different types:
```shell
cat heap.json |
    ruby -rjson -ne ' puts JSON.parse($_).values_at("file","line","type").join(":") ' |
    sort        |
    uniq -c     |
    sort -n     |
    tail -4
```

rbtrace
---
require rbtrace into a process
```ruby
% cat server.rb
require 'rbtrace'

class String
  def multiply_vowels(num)
    @test = 123
    gsub(/[aeiou]/){ |m| m*num }
  end
end

while true
  proc {
    Dir.chdir("/tmp") do
      Dir.pwd
      Process.pid
      'hello'.multiply_vowels(3)
      sleep rand*0.5
    end
  }.call
end
```
force SideKiq to dump a its heap with:
```shell
bundle exec rbtrace -p PID -e "load 'path_to_file_with_more_commands.rb'"
bundle exec rbtrace -p $SIDEKIQ_PID -e 'Thread.new{GC.start;require "objspace";io=File.open("/tmp/ruby-heap.dump", "w"); ObjectSpace.dump_all(output: io); io.close}'
```

```shell
rbtrace -p PID -e 'Thread.new{require "objspace"; ObjectSpace.trace_object_allocations_start; GC.start(); ObjectSpace.dump_all(output: File.open("heap.json", "w"))}.join'  
```

```ruby
system("rbtrace -p #{Process.pid} -e 'load \"#{Rails.root}/script/heap_dump.rb\"'").  
```

GC.stat
```shell
bundle exec rbtrace -p PID -e 'GC.stat'
```

From Dump to Data
---
heapy
```shell
gem install heapy
```

```shell
bundle exec heapy read /tmp/ruby-heap.dump
```

analyze the heap dump
---
```ruby
require 'json'
class Analyzer
  def initialize(filename)
    @filename = filename
  end

  def analyze
    data = []
    File.open(@filename) do |f|
        f.each_line do |line|
          data << (parsed=JSON.parse(line))
        end
    end

    data.group_by{|row| row["generation"]}
        .sort{|a,b| a[0].to_i <=> b[0].to_i}
        .each do |k,v|
          puts "generation #{k} objects #{v.count}"
        end
  end
end

Analyzer.new(ARGV[0]).analyze
```
