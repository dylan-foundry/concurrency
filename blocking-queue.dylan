module: concurrency
synopsis: Queues for blockable work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <blocking-queue> (<locked-queue>)
  slot queue-blocked-work :: <list> = #();
end class;

define method %unblock (queue :: <blocking-queue>, work :: <locked-work>)
 => (was-blocked? :: <boolean>)
  with-lock (work-lock(work))
    let blocked = work-blocked?(work);
    if (~blocked)
      %enqueue-internal(queue, work);
    end;
    blocked;
  end;
end method;

define method %unblock-all (queue :: <blocking-queue>)
  queue-blocked-work(queue) :=
    choose(curry(%unblock, queue),
           queue-blocked-work(queue));
end method;

define method %empty? (queue :: <blocking-queue>)
 => (empty? :: <boolean>);
  %unblock-all(queue);
  next-method();
end method;

define method %enqueue-internal (queue :: <blocking-queue>, work :: <locked-work>)
 => ();
  if (work-blocked?(work))
    queue-blocked-work(queue) := add!(queue-blocked-work(queue), work);
  else
    next-method();
  end;
end method;

define method %enqueue (queue :: <blocking-queue>, work :: <locked-work>)
 => ();
  with-lock (work-lock(work))
    next-method();
  end;
end method;
