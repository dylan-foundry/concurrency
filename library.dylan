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
    executor-shutdown,
    <single-thread-executor>,
    <fixed-thread-executor>;

  export
    <queue>,
    queue-name,
    queue-backlog,
    enqueue,
    dequeue,
    <locked-queue>,
    stop-queue,
    interrupt-queue,
    <queue-condition>,
    queue-condition-thread,
    queue-condition-queue,
    <queue-interrupt>,
    <queue-stopped>;

  export
    <work>,
    work-perform,
    work-thread,
    work-started?,
    work-finished?,
    <locked-work>,
    work-wait;

end module;
