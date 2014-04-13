module: concurrency
synopsis: Executors.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define abstract class <executor> (<object>)
  constant slot executor-name :: <string> = "executor",
    init-keyword: name:;
end class;

// Request that this executor do some work.
define generic executor-request (executor :: <executor>, work :: <object>)
 => ();

// Convenience method that converts a <function> into a <work> object.
// The function must not have any required arguments.
define method executor-request (executor :: <executor>, work :: <function>)
 => ();
  executor-request(executor, make(<work>, function: work));
end method;
