module: concurrency
synopsis: Locked queues.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

/* Locked multi-reader multi-writer queue
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


/* Find out how much outstanding work the queue has
 */
define method queue-backlog (queue :: <locked-queue>)
 => (size-of-queue :: <integer>);
  with-lock (queue-lock(queue))
    size(queue-deque(queue));
  end;
end method;

/* Enqueue a work item onto the queue
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
