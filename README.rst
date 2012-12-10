Concurrency
###########

This library provides various concurrency utilities for use with Dylan
programs.

Basic Abstractions
------------------

The abstractions in this library are somewhat inspired by javax.concurrency.

Executors
~~~~~~~~~

Executors perform work that is requested from them asynchronously.

Currently, all executores use their own private threads.

Queues
~~~~~~

Queues are job-streams that can have items enqueued and subsequently dequeued.

These form the synchronization mechanism for thread executors.

Work
~~~~

Work objects represent something to be done.
