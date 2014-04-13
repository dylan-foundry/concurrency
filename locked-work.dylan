module: concurrency
synopsis: Locked work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <locked-work> (<work>)
  slot work-lock :: <simple-lock>;
  slot work-notification :: <notification>;
end class;

define method initialize (work :: <locked-work>, #rest keys, #key, #all-keys)
 => ();
  next-method();
  work-lock(work) := make(<simple-lock>);
  work-notification(work) := make(<notification>, lock: work-lock(work));
end method;

define constant $work-started = #"started";
define constant $work-finished = #"finished";
define constant <work-state> = one-of($work-started, $work-finished);

// Wait for a work item to reach the given state.  Valid states are
// $work-started and $work-finished.
define method work-wait (work :: <locked-work>, state :: <work-state>)
  => ();
  with-lock (work-lock(work))
    iterate again ()
      synchronize-side-effects();
      case
        state == $work-started & work-started?(work) =>
          #t;
        state == $work-finished & work-finished?(work) =>
          #t;
        otherwise =>
          wait-for(work-notification(work));
          again();
      end;
    end;
  end;
end method;

define method work-start (work :: <locked-work>)
 => ();
  with-lock (work-lock(work))
    next-method();
    release-all(work-notification(work));
  end;
end method;

define method work-finish (work :: <locked-work>)
 => ();
  with-lock (work-lock(work))
    next-method();
    release-all(work-notification(work));
  end;
end method;
