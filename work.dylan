module: concurrency
synopsis: Work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define constant <work-state> =
  one-of(ready:, blocked:, started:, finished:);

define class <work> (<object>)
  // name of this work item
  constant slot work-name :: false-or(<string>) = #f,
    init-keyword: name:;
  // function performing the work
  constant slot work-function :: <function>,
    required-init-keyword: function:;
  // current state of this work
  slot work-state :: <work-state> = ready:;
  // thread that processed this work item
  slot work-thread :: false-or(<thread>) = #f;
end class;

define function work-blocked? (work :: <work>)
  => (blocked? :: <boolean>);
  work-state(work) == blocked:;
end function;

define function work-started? (work :: <work>)
  => (started? :: <boolean>);
  let state :: <work-state> = work-state(work);
  state == started: | state == finished:;
end function;

define function work-finished? (work :: <work>)
  => (finished? :: <boolean>);
  work-state(work) == finished:;
end function;

define method work-perform (work :: <work>)
  => ();
  %work-started(work);
  block ()
    work-execute(work);
  cleanup
    %work-finished(work);
  end;
end method;

define method work-execute (work :: <work>)
  work.work-function();
end method;

define method %work-switch-state (work :: <work>, state :: <work-state>)
 => ();
  work-state(work) := state;
end method;

define method %work-started (work :: <work>)
 => ();
  work-thread(work) := current-thread();
  %work-switch-state(work, started:);
end method;

define method %work-finished (work :: <work>)
 => ();
  %work-switch-state(work, finished:);
end method;
