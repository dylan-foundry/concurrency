module: concurrency
synopsis: Queues for blockable work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <blocking-queue> (<locked-queue>)
  constant slot queue-blocked-work :: <deque> = make(<deque>);
end class;

define method unblock (queue :: <blocking-queue>)
 => ();
  let unblocked = #();
  for (work :: <blocking-work> in queue-blocked-work(queue))
    if (~work-blocked?(work))
      %enqueue(queue, work);
      unblocked := add!(unblocked, work);
    end;
  end;
  for (work :: <blocking-work> in unblocked)
    remove!(queue-blocked-work(queue), work);
  end;
end method;

define method %empty? (queue :: <blocking-queue>)
 => (empty? :: <boolean>);
  unblock(queue);
  next-method();
end method;

define method %enqueue (queue :: <blocking-queue>, work :: <blocking-work>)
 => ();
  if (work-blocked?(work))
    add!(queue-blocked-work(queue), work);
  else
    next-method();
  end;
end method;

define method %dequeue (queue :: <blocking-queue>)
  => (object :: <object>);
  next-method();
end method;
