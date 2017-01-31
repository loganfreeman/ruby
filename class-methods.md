```ruby
 class << self
    def included(base)
      base.send :extend, ClassMethods
    end
  end
```
