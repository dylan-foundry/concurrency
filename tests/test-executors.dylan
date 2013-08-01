module: concurrency-test-suite
synopsis: Tests for executors
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define test basic-<synchronous-executor>-test ()
  let executor = make(<synchronous-executor>,
                      name: "Synchronous Test Executor");
  let work-items = make-simple-work();
  for(work in work-items)
    executor-request(executor, work);
  end for;
  executor-run(executor);
  check-work-finished(work-items);
end test;

define test basic-<single-thread-executor>-test ()
  let executor = make(<single-thread-executor>,
                      name: "Single-thread Test Executor",
                      autostart?: #f);
  test-thread-executor(executor);
end test;

define test basic-<fixed-thread-executor>-test ()
  let executor = make(<fixed-thread-executor>,
                      name: "Fixed-thread Test Executor",
                      thread-count: 2,
                      autostart?: #f);
  test-thread-executor(executor);
end test;

define method test-thread-executor(executor)
  let early-work-items = make-simple-work();
  let started-work-items = make-simple-work();

  for (work in early-work-items)
    executor-request(executor, work);
  end for;

  executor-start(executor);
  
  for (work in started-work-items)
    executor-request(executor, work);
  end for;

  executor-stop(executor, drain?: #t, join?: #t);

  check-work-finished(early-work-items);
  check-work-finished(started-work-items);
end method;
