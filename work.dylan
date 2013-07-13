module: concurrency
synopsis: Work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define constant <work-state> =
  one-of(new:, started:, finished:);

define class <work> (<object>)
  // function performing the work
  constant slot work-function :: <function>,
    required-init-keyword: function:;
  // current state of this work
  slot work-state :: <work-state> = new:;
  // thread that processed this work item
  slot work-thread :: false-or(<thread>) = #f;
end class;

define function work-started?(work :: <work>)
  => (started? :: <boolean>);
  let state :: <work-state> = work-state(work);
  state == started: | state == finished:;
end function;

define function work-finished?(work :: <work>)
  => (started? :: <boolean>);
  work-state(work) == finished:;
end function;

define generic work-start (work :: <work>)
 => ();

define generic work-finish (work :: <work>)
 => ();

define method work-perform (work :: <work>)
  => ();
  work-start(work);
  block ()
    work-execute(work);
  cleanup
    work-finish(work);
  end;
end method;

define method work-start (work :: <work>)
 => ();
  work-thread(work) := current-thread();
  work-state(work) := started:;
end method;

define method work-finish (work :: <work>)
 => ();
  work-state(work) := finished:;
end method;

define method work-execute (work :: <work>)
  work.work-function();
end method;
