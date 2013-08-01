module: concurrency
synopsis: Queues.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE


define abstract class <queue> (<object>)
  constant slot queue-name :: false-or(<string>),
    init-keyword: name:;
end class;

define generic enqueue (queue :: <queue>, #rest objects)
 => ();

define generic dequeue (queue :: <queue>)
 => (object :: <object>);

define generic try-dequeue (queue :: <queue>)
 => (object :: false-or(<object>));
