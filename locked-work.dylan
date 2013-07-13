module: concurrency
synopsis: Locked work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

/* Locked work items that allow waiting for state transitions
 */
define class <locked-work> (<work>)
  slot work-lock :: <simple-lock>;
  slot work-notification :: <notification>;
end class;

/* Initializer - create the required lock and notification
 */
define method initialize (work :: <locked-work>, #rest keys, #key, #all-keys)
 => ();
  next-method();
  work-lock(work) := make(<simple-lock>);
  work-notification(work) := make(<notification>, lock: work-lock(work));
end method;

/* Wait for the given work item to reach the given state
 */
define method work-wait (work :: <locked-work>, state :: <work-state>)
  => ();
  with-lock (work-lock(work))
    iterate again ()
      synchronize-side-effects();
      case
        state == started: & work-started?(work) =>
          #t;
        state == finished: & work-finished?(work) =>
          #t;
        otherwise =>
          wait-for(work-notification(work));
          again();
      end;
    end;
  end;
end method;

/* Override - wake waiters when work is started
 */
define method work-start (work :: <locked-work>)
 => ();
  with-lock (work-lock(work))
    next-method();
    release-all(work-notification(work));
  end;
end method;

/* Override - wake waiters when work is finished
 */
define method work-finish (work :: <locked-work>)
 => ();
  with-lock (work-lock(work))
    next-method();
    release-all(work-notification(work));
  end;
end method;
