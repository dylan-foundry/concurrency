module: concurrency
synopsis: Executors.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define abstract class <executor> (<object>)
  constant slot executor-name :: <string> = "executor",
    init-keyword: name:;
  constant slot executor-queue :: <queue> = make(<locked-queue>),
    init-keyword: queue:;
end class;

define generic executor-request (executor :: <executor>, work :: <object>)
 => ();

define method executor-request (executor :: <executor>, work :: <work>)
 => ();
  enqueue(executor-queue(executor), work);
end method;

define method executor-request (executor :: <executor>, work :: <function>)
 => ();
  executor-request(executor, make(<work>, function: work));
end method;
