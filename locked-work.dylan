module: concurrency
synopsis: Locked work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

/* Locked work items that allow waiting for state transitions
 */
define class <locked-work> (<work>)
  // lock and notification for work item state
  // can be used to wait for state changes
  slot work-lock :: <simple-lock>;
  slot work-notification :: <notification>;
  // lock synchronizing queue interaction (enqueue,block,unblock)
  // depends on the respective queue lock once we have a queue
  constant slot work-scheduling-lock :: <simple-lock> = make(<simple-lock>);
end class;

/* Initializer - create the required lock and notification
 */
define method initialize (work :: <locked-work>, #rest keys, #key, #all-keys)
 => ();
  next-method();
  work-lock(work) := make(<simple-lock>);
  work-notification(work) := make(<notification>, lock: work-lock(work));
end method;

/* Override - lock and notify when switching state
 */
define method work-switch-state (work :: <locked-work>, state :: <work-state>)
  => ();
  with-lock (work-lock(work))
    next-method();
    release-all(work-notification(work));
  end;
end method;

define method work-start (work :: <locked-work>)
  => ();
  with-lock (work-lock(work))
    next-method();
  end;
end method;

define method work-finish (work :: <locked-work>)
  => ();
  with-lock (work-lock(work))
    next-method();
  end;
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
