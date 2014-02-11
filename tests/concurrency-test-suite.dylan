module: concurrency-test-suite
synopsis: Test suite for the concurrency library.

define test basic-concurrency-test ()
end test basic-concurrency-test;

define suite concurrency-test-suite ()
  test basic-concurrency-test;
end suite;
