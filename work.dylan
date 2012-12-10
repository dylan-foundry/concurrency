module: concurrency
synopsis: Work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <work> (<object>)
  // function performing the work
  constant slot work-function :: <function>,
    required-init-keyword: function:;

  // if this work item has been started
  slot work-started? :: <boolean> = #f;
  // if this work item has been finished
  slot work-finished? :: <boolean> = #f;
  // thread that processed this work item
  slot work-thread :: false-or(<thread>) = #f;
end class;

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
  work-started?(work) := #t;
end method;

define method work-finish (work :: <work>)
 => ();
  work-finished?(work) := #t;
end method;

define method work-execute (work :: <work>)
  work.work-function();
end method;
