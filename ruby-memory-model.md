- [Ruby Memory Model](https://docs.google.com/document/d/1pVzU8w_QF44YzUCCab990Q_WZOdhpKolCIHaiXG-sPw/edit#heading=h.gh0cw4u6nbi5)

Within a single Thread, reads and writes must behave as if they are executed in the order specified by the program. Compilers and processors may reorder the reads and writes executed within a single Thread only when the reordering does not change the behavior within the Thread. Because of this reordering, the execution order observed by one Thread may differ from the order perceived by another.

A read r of a variable v is allowed to observe a write w to v if both of the following hold:
- r does not happen-before w.
- There is no other write w' to v that happens after w but before r.
