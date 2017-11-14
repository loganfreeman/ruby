[active_interaction](https://github.com/AaronLasseigne/active_interaction)
---
ActiveInteraction gives you a place to put your business logic. It also helps you write safer code by validating that your inputs conform to your expectations. 

[celluloid](https://github.com/celluloid/celluloid)
---
Actor-based concurrent object framework for Ruby.

Much of the difficulty with building concurrent programs in Ruby arises because the object-oriented mechanisms for structuring code, such as classes and inheritance, are separate from the concurrency mechanisms, such as threads and locks. Celluloid combines these into a single structure, an active object running within a thread, called an "actor", or in Celluloid vernacular, a "cell".

Each actor is a concurrent object running in its own thread, and every method invocation is wrapped in a fiber that can be suspended whenever it calls out to other actors, and resumed when the response is available. 
