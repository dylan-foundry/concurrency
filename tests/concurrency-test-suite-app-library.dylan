module: dylan-user
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define library concurrency-test-suite-app
  use testworks;
  use concurrency-test-suite;
end library;

define module concurrency-test-suite-app
  use testworks;
  use concurrency-test-suite;
end module;
