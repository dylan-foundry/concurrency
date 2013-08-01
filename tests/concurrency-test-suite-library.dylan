module: dylan-user
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define library concurrency-test-suite
  use common-dylan;
  use io;
  use concurrency;
  use testworks;

  export concurrency-test-suite;
end library;

define module concurrency-test-suite
  use common-dylan, exclude: { format-to-string };
  use format;
  use format-out;
  use concurrency;
  use testworks;

  export concurrency-test-suite;
end module;
