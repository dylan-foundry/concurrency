module: dylan-user

define library concurrency
  use common-dylan;
  use io;

  export concurrency;
end library;

define module concurrency
  use common-dylan, exclude: { format-to-string };
  use format-out;
  use threads;

  export
    <executor>,
    executor-name,
    executor-request,
    <thread-executor>,
    executor-start,
    executor-stop,
    executor-join,
    <single-thread-executor>,
    <fixed-thread-executor>,
    <synchronous-executor>,
    executor-run,
    executor-run-one;

  export
    <queue>,
    queue-name,
    enqueue,
    dequeue,
    try-dequeue,
    <locked-queue>,
    stop-queue,
    interrupt-queue,
    <blocking-queue>,
    <queue-condition>,
    queue-condition-thread,
    queue-condition-queue,
    <queue-interrupt>,
    <queue-stopped>;

  export
    <work>,
    work-name,
    <work-state>,
    work-state,
    work-perform,
    work-thread,
    work-started?,
    work-finished?,
    <locked-work>,
    work-wait,
    <dependency-work>,
    work-dependencies;

end module;
