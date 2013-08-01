module: concurrency-test-suite

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
