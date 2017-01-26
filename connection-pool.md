[connection_pool](https://github.com/mperham/connection_pool)
---
Create a pool of objects to share amongst the fibers or threads in your Ruby application:
```ruby
$memcached = ConnectionPool.new(size: 5, timeout: 5) { Dalli::Client.new }
```
