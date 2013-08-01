module: concurrency-test-suite
synopsis: Test suite for the concurrency library.

define suite concurrency-test-suite ()
  test basic-<synchronous-executor>-test;
  test basic-<single-thread-executor>-test;
  test basic-<fixed-thread-executor>-test;

  test basic-dependency-test;
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

define test basic-dependency-test ()
  let executor = make(<fixed-thread-executor>,
                       name: "Dependency Test Executor",
                       thread-count: 8,
                       queue: make(<blocking-queue>));

  let work = make-dependency-work();

  for (w in work)
    executor-request(executor, w);
  end;

  executor-stop(executor, drain?: #t, join?: #t);

  check-work-finished(work);
end test;

define method make-dependency-work()
 => (work :: <list>);
  let all = #();
  let iwork = #();
  for (i from 0 below 5)
    let jwork = #();
    for (j from 0 below 5)
      let kwork = #();
      for (k from 0 below 5)
        local method kmethod (i, j, k) => ();
                format-out("Performing %d.%d.%d\n", i, j, k);
                force-out();
              end method;
        let kw = make(<dependency-work>,
                      name: format-to-string("Dependency Work %d.%d.%d", i, j, k),
                      function: curry(kmethod, i, j, k));
        kwork := add!(kwork, kw);
        all := add!(all, kw);
      end for;

      local method jmethod (deps, i, j) => ();
              let name = format-to-string("%d.%d", i, j);
              format-out("Performing %d.%d\n", i, j);
              force-out();
              for(w in deps)
                let c = format-to-string("%s done before %s", work-name(w), name);
                //check-true(c, work-finished?(w));
              end;
              force-output(*standard-output*);
            end method;
      let jw = make(<dependency-work>,
                    name: format-to-string("Dependency Work %d.%d", i, j),
                    function: curry(jmethod, kwork, i, j),
                    dependencies: kwork);
      jwork := add!(jwork, jw);
      all := add!(all, jw);
    end for;

    local method imethod (deps, i) => ();
            let name = format-to-string("%d", i);
            format-out("Performing %d\n", i);
            force-out();
            for(w in deps)
              let c = format-to-string("%s done before %s", work-name(w), name);
              //check-true(c, work-finished?(w));
            end;
            force-output(*standard-output*);
          end method;
    format-out("Generating %d\n", i);
    force-out();
    force-output(*standard-output*);
    let iw = make(<dependency-work>,
                  name: format-to-string("Dependency Work %d", i),
                  function: curry(imethod, jwork, i),
                  dependencies: jwork);
    iwork := add!(iwork, iw);
    all := add!(all, iw);
  end for;
  all;
end method;

