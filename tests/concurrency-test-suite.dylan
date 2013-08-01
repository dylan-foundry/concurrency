module: concurrency-test-suite
synopsis: Test suite for the concurrency library.

define suite concurrency-test-suite ()
  test basic-<synchronous-executor>-test;
  test basic-<single-thread-executor>-test;
  test basic-<fixed-thread-executor>-test;
end suite;

define method make-simple-work()
  let work = #();
  for (i from 0 below 5)
    work := add!(work, make(<locked-work>,
                            name: format-to-string("Work %d", i),
                            function: method()
                                        #t
                                      end method));
  end;
  reverse(work);
end method;

define method check-work-finished(work-items :: <sequence>)
  for (work in work-items)
    check-true(format-to-string("%s finished", work-name(work)),
               work-finished?(work));
  end;
end method;

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
