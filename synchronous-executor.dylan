module: concurrency
synopsis: Synchronous executors.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

/* Synchronous non-threaded executor
 * 
 * Intended as a replacement for executors in single-threaded environments.
 * It is, however, thread-safe and can be used between different threads,
 * complete with stopping and interruption.
 * 
 * This is provided so that the priority and dependency mechanisms of queues
 * can easily be used in single-threaded environments.
 *
 * One use case for this is as a single-threaded backend to a build system
 * that uses the work abstraction to resolve job priorities and dependencies.
 */
define class <synchronous-executor> (<executor>)
end class;

define method executor-run (executor :: <synchronous-executor>)
 => (work-performed :: <list>);
  let queue = executor-queue(executor);
  let performed = #();
  block (return)
    iterate more-work()
      let work :: false-or(<work>) = try-dequeue(queue);
      if (~work)
        return();
      else
        work-perform(work);
        performed := add(performed, work);
        more-work();
      end;
    end;
  exception (i :: <queue-condition>)
    // we got interrupted or stopped, quit processing
  end;
  performed;
end method;

define method executor-run-one (executor :: <synchronous-executor>)
 => (work-performed :: false-or(<work>));  
  let queue = executor-queue(executor);
  block (return)
    let work :: false-or(<work>) = dequeue(queue);
    if (work)
      work-perform(work);
    end;
    return(work);
  exception (i :: <queue-condition>)
    // we got interrupted or stopped
    return(#f);
  end;
end method;
