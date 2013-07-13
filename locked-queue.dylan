module: concurrency
synopsis: Locked queues.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

/* Locked multi-reader multi-writer queue
 *
 * This is a base class for specific implementations
 * that modify queueing behaviour.
 *
 * A notification is used for synchronization.
 * The associated lock is used for all queue state.
 *
 *
 * Queues can be STOPPED so that no further work will be
 * accepted and processing will end once all previously
 * submitted work has been finished.
 *
 * After stopping, all further enqueue operations will
 * signal <queue-stopped>.
 *
 * Dequeue operations will continue until the queue has
 * been drained, whereupon they will also be signalled.
 *
 *
 * Queues can be INTERRUPTED so that no further work will
 * be accepted or begun. Work that has already been started
 * will continue.
 *
 * Interrupting implies stopping, so enqueue operations
 * will be signalled <queue-stopped>.
 *
 * Dequeue operations will signal <queue-interrupt>.
 *
 */
define class <locked-queue> (<queue>)
  // Internal data structure
  constant slot queue-deque :: <deque> = make(<deque>);

  // Synchronization
  slot queue-lock :: <simple-lock>;
  slot queue-notification :: <notification>;

  // State flags
  slot queue-stopped? :: <boolean> = #f;
  slot queue-interrupted? :: <boolean> = #f;
end class;

/* Initializer for thread queues
 */
define method initialize (queue :: <locked-queue>, #rest keywords, #key, #all-keys)
 => ();
  next-method();
  queue-lock(queue) := make(<simple-lock>);
  queue-notification(queue) := make(<notification>, lock: queue-lock(queue));
end method;

/* Conditions related to <locked-queue> operations
 */
define abstract class <queue-condition> (<condition>)
  constant slot queue-condition-thread :: <thread>,
    required-init-keyword: thread:;
  constant slot queue-condition-queue :: <locked-queue>,
    required-init-keyword: queue:;
end class;

/* Signalled when the queue has been interrupted
 */
define class <queue-interrupt> (<queue-condition>)
end class;

/* Signalled when the queue has been stopped
 */
define class <queue-stopped> (<queue-condition>)
end class;


/* Enqueue a work item onto the queue
 *
 * May signal <queue-stopped> when
 * the queue no longer accepts work.
 */
define method enqueue (queue :: <locked-queue>, object :: <object>)
 => ();
  with-lock (queue-lock(queue))
    if (queue-stopped?(queue))
      signal(make(<queue-stopped>,
                  thread: current-thread(),
                  queue: queue));
    else
      add!(queue-deque(queue), object);
      sequence-point();
      release(queue-notification(queue));
    end;
  end;
end method;

/* Dequeue the next available item from the queue
 *
 * May signal <queue-interrupt> or <queue-stopped>
 * when the queue has reached the respective state.
 */
define method dequeue (queue :: <locked-queue>)
 => (object :: <object>);
  let deque = queue-deque(queue);

  with-lock (queue-lock(queue))
    iterate repeat ()
      synchronize-side-effects();
      if (queue-interrupted?(queue))
        signal(make(<queue-interrupt>,
                    thread: current-thread(),
                    queue: queue));
      end;
      if (empty?(deque))
        if (queue-stopped?(queue))
          signal(make(<queue-stopped>,
                      thread: current-thread(),
                      queue: queue));
        else
          wait-for(queue-notification(queue));
          repeat();
        end;
      else
        pop-last(deque);
      end;
    end;
  end;
end method;

/* Stops the queue so that submitted work can still continue
 *
 * Submitters will be signalled <queue-stopped>
 * in ENQUEUE if they try to submit further work.
 *
 * Receivers will be signalled <queue-stopped>
 * in DEQUEUE once the queue has been drained.
 */
define method stop-queue (queue :: <locked-queue>)
 => ();
  with-lock (queue-lock(queue))
    queue-stopped?(queue) := #t;
    sequence-point();
    release-all(queue-notification(queue));
  end;
end method;

/* Interrupts the queue, abandoning submitted work
 *
 * Submitters will be signalled <queue-stopped>
 * in ENQUEUE if they try to submit further work.
 *
 * Receivers will be signalled <queue-interrupt>
 * at the first DEQUEUE operation they perform.
 */
define method interrupt-queue (queue :: <locked-queue>)
 => ();
  with-lock (queue-lock(queue))
    queue-stopped?(queue) := #t;
    queue-interrupted?(queue) := #t;
    sequence-point();
    release-all(queue-notification(queue));
  end;
end method;
