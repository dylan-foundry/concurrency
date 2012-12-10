module: concurrency
synopsis: Executors.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define abstract class <executor> (<object>)
  constant slot executor-name :: <string> = "executor",
    init-keyword: name:;
end class;

define generic executor-request (executor :: <executor>, work :: <object>)
 => ();

define method executor-request (executor :: <executor>, work :: <function>)
 => ();
  executor-request(executor, make(<work>, function: work));
end method;
