***********
Concurrency
***********

.. current-library:: concurrency
.. current-module:: concurrency

This library provides various concurrency utilities for use with Dylan
programs.

Basic Abstractions
==================

The abstractions in this library are somewhat inspired by ``javax.concurrency``.

Executors
---------

Executors perform work that is requested from them asynchronously.

Currently, all executors use their own private threads.

See: :class:`<executor>`, :class:`<fixed-thread-executor>`, :class:`<thread-executor>`,
and :class:`<single-thread-executor>`.

Queues
------

Queues are job-streams that can have items enqueued and subsequently dequeued.

These form the synchronization mechanism for thread executors.

See: :class:`<queue>`, :class:`<locked-queue>`.

Work
----

Work objects represent something to be done.

See: :class:`<work>`, :class:`<locked-work>`.

Library Reference
=================

Executors
---------

.. class:: <executor>
   :abstract:

   :superclasses: :drm:`<object>`

   :keyword name:

   :operations:

     * :gf:`executor-name`
     * :gf:`executor-request`

.. class:: <thread-executor>
   :abstract:

   :superclasses: :class:`<executor>`

   :keyword queue:

   :operations:

     * :gf:`executor-shutdown`

.. class:: <fixed-thread-executor>

   :superclasses: :class:`<thread-executor>`

   :keyword thread-count:

.. class:: <single-thread-executor>

   :superclasses: :class:`<thread-executor>`

.. generic-function:: executor-name

   :signature: executor-name (executor) => (name)

   :parameter executor: An instance of :class:`<executor>`.
   :value name: An instance of :drm:`<string>`.

.. generic-function:: executor-request

   :signature: executor-request (executor work) => ()

   :parameter executor: An instance of :class:`<executor>`.
   :parameter work: An instance of :drm:`<object>`.

.. method:: executor-request
   :specializer: <function>

   :signature: executor-request (executor function) => ()

   :parameter executor: An instance of :class:`<executor>`.
   :parameter work: An instance of :drm:`<function>`.

.. method:: executor-request
   :specializer: <work>

   :signature: executor-request (executor work) => ()

   :parameter executor: An instance of :class:`<executor>`.
   :parameter work: An instance of :class:`<work>`.

.. generic-function:: executor-shutdown

   :signature: executor-shutdown (executor #key join? drain?) => ()

   :parameter executor: An instance of :class:`<thread-executor>`.
   :parameter #key join?: An instance of :drm:`<boolean>`.
   :parameter #key drain?: An instance of :drm:`<boolean>`.


Queues
------

.. class:: <queue>
   :abstract:

   :superclasses: :drm:`<object>`

   :keyword name:

   :operations:

     * :gf:`dequeue`
     * :gf:`enqueue`
     * :gf:`queue-name`

.. class:: <locked-queue>

   :superclasses: :class:`<queue>`

   :operations:

     * :gf:`interrupt-queue`
     * :gf:`stop-queue`

.. generic-function:: dequeue

   :signature: dequeue (queue) => (object)

   :parameter queue: An instance of :class:`<queue>`.
   :value object: An instance of :drm:`<object>`.

.. generic-function:: enqueue

   :signature: enqueue (queue object) => ()

   :parameter queue: An instance of :class:`<queue>`.
   :parameter object: An instance of :drm:`<object>`.

.. generic-function:: queue-name

   :signature: queue-name (queue) => (name?)

   :parameter queue: An instance of :class:`<queue>`.
   :value name?: An instance of ``false-or(<string>)``.

.. generic-function:: interrupt-queue

   :signature: interrupt-queue (queue) => ()

   :parameter queue: An instance of :class:`<locked-queue>`.

.. generic-function:: stop-queue

   :signature: stop-queue (queue) => ()

   :parameter queue: An instance of :class:`<locked-queue>`.

.. class:: <queue-condition>
   :abstract:

   :superclasses: :drm:`<condition>`

   :keyword queue:
   :keyword thread:

.. class:: <queue-interrupt>

   :superclasses: :class:`<queue-condition>`


.. class:: <queue-stopped>

   :superclasses: :class:`<queue-condition>`

.. generic-function:: queue-condition-queue

   :signature: queue-condition-queue (condition) => (queue)

   :parameter condition: An instance of :class:`<queue-condition>`.
   :value queue: An instance of :class:`<queue>`.

.. generic-function:: queue-condition-thread

   :signature: queue-condition-thread (condition) => (thread)

   :parameter condition: An instance of :class:`<queue-condition>`.
   :value thread: An instance of :drm:`<thread>`.


Work
----

.. class:: <work>

   :superclasses: :drm:`<object>`

   :keyword function:

   :operations:

   * :gf:`work-finished?`
   * :gf:`work-perform`
   * :gf:`work-started?`
   * :gf:`work-thread`

.. class:: <locked-work>

   :superclasses: :class:`<work>`

   :operations:

   * :gf:`work-wait`

.. generic-function:: work-finished?

   :signature: work-finished? (work) => (finished?)

   :parameter work: An instance of :class:`<work>`.
   :value finished?: An instance of :drm:`<boolean>`.

.. generic-function:: work-perform

   :signature: work-perform (work) => ()

   :parameter work: An instance of :class:`<work>`.

.. generic-function:: work-started?

   :signature: work-started? (work) => (started?)

   :parameter work: An instance of :class:`<work>`.
   :value started?: An instance of :drm:`<boolean>`.

.. generic-function:: work-thread

   Return the thread on which the work was executed.

   :signature: work-thread (work) => (thread)

   :parameter work: An instance of :class:`<work>`.
   :value thread: An instance of :class:`<thread>`.

.. generic-function:: work-wait

   :signature: work-wait (work state) => ()

   :parameter work: An instance of :class:`<locked-work>`.
   :parameter state: An instance of :drm:`<symbol>`. One of ``started:`` or ``finished:``.

