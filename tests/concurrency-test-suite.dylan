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
