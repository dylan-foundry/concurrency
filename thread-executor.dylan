module: concurrency
synopsis: Executors implemented using threads.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define abstract class <thread-executor> (<executor>)
  constant slot executor-queue :: <queue> = make(<locked-queue>),
    init-keyword: queue:;

  slot executor-threads :: <sequence>;
end class;

define method executor-request (executor :: <executor>, work :: <work>)
 => ();
  enqueue(executor-queue(executor), work);
end method;

define method executor-shutdown (executor :: <thread-executor>,
                                 #key drain? :: <boolean> = #t,
                                      join? :: <boolean> = #t)
 => ();
  let queue = executor-queue(executor);
  if(drain?)
    stop-queue(queue);
  else
    interrupt-queue(queue);
  end;
  if(join?)
    executor-join(executor);
  end;
end method;

define method executor-join (executor :: <thread-executor>)
 => ();
  let threads = executor-threads(executor);
  until (empty?(threads))
    let joined = apply(join-thread, threads);
    threads := remove!(threads, joined);
  end;
end method;

define method %executor-thread (executor :: <executor>, id :: <integer>)
 => ();
  let queue = executor-queue(executor);
  block ()
    iterate more-work()
      let work :: <work> = dequeue(queue);
      work-perform(work);
      more-work();
    end;
  exception (i :: <queue-condition>)
    // we got interrupted or stopped, quit processing
  end;
end method;


define class <single-thread-executor> (<thread-executor>)
end class;

define method initialize (executor :: <single-thread-executor>, #rest args, #key, #all-keys)
 => ();
  next-method();
  let threads = make(<simple-object-vector>, size: 1);
  threads[0] := make(<thread>,
                     name: executor-name(executor),
                     function: curry(%executor-thread, executor, 0));
  executor-threads(executor) := threads;
end method;


define class <fixed-thread-executor> (<thread-executor>)
  constant slot executor-thread-count :: <integer> = 1,
    init-keyword: thread-count:;
end class;

define method initialize (executor :: <fixed-thread-executor>, #rest args, #key, #all-keys)
 => ();
  next-method();
  let size = executor-thread-count(executor);
  let threads = make(<simple-object-vector>, size: size);
  let name = executor-name(executor);
  for(id from 0 below size)
    threads[id] := make(<thread>,
                        name: concatenate(name, " ", integer-to-string(id)),
                        function: curry(%executor-thread, executor, id));
  end for;
  executor-threads(executor) := threads;
end method;
