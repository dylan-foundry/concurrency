module: concurrency
synopsis: Queues for blockable work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <blocking-queue> (<locked-queue>)
  constant slot queue-blocked-work :: <deque> = make(<deque>);
end class;

define method %unblock (queue :: <blocking-queue>, work :: <work>)
  %enqueue(queue, work);
  remove!(queue-blocked-work(queue), work);
end method;

define method %unblock-all (queue :: <blocking-queue>)
  let unblocked = choose(complement(work-blocked?),
                         queue-blocked-work(queue));
  for (work :: <work> in unblocked)
    %unblock(queue, work);
  end;
end method;

define method %empty? (queue :: <blocking-queue>)
 => (empty? :: <boolean>);
  %unblock-all(queue);
  next-method();
end method;

define method %enqueue (queue :: <blocking-queue>, work :: <work>)
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
