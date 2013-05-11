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

define method executor-execute (executor :: <synchronous-executor>)
 => (work-performed :: <list>);
  let queue = executor-queue(executor);
  let performed = #();
  block ()
    iterate more-work()
      let work :: <work> = dequeue(queue);
      work-perform(work);
      performed := add(performed, work);
      more-work();
    end;
  exception (i :: <queue-condition>)
    // we got interrupted or stopped, quit processing
  end;
  performed;
end method;

define method executor-execute-one (executor :: <synchronous-executor>)
 => (work-performed :: false-or(<work>));  
  let queue = executor-queue(executor);
  block (return)
    let work :: <work> = dequeue(queue);
    work-perform(work);
    return(work);
  exception (i :: <queue-condition>)
    // we got interrupted or stopped
    return(#f);
  end;
end method;
