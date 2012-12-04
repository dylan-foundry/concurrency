module: dylan-user

define library concurrency
  use common-dylan;
  use io;

  export concurrency;
end library;

define module concurrency
  use common-dylan, exclude: { format-to-string };
  use format-out;
end module;
