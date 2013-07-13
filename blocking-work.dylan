module: concurrency
synopsis: Blockable work items.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <blocking-work> (<locked-work>)
  // other items this work depends on
  // immutability intended to discourage cycles
  constant slot work-dependencies :: <list> = #(),
    init-keyword: dependencies:;

  // items that depend on this work being done
  slot work-dependents :: <list> = #();

  // lock for finishing dependencies
  constant slot work-finish-lock :: <simple-lock> = make(<simple-lock>);
  // dependencies not yet finished
  slot work-unfinished-dependencies :: <list> = #();
end class;

define method initialize (work :: <blocking-work>, #rest keys, #key, #all-keys)
 => ();
  next-method();
  with-lock (work-finish-lock(work))
    let blocked? :: <boolean> = #f;
    for (dependency :: <blocking-work> in work-dependencies(work))
      if (work-add-dependent(dependency, work))
        work-unfinished-dependencies(work) := add!(work-unfinished-dependencies(work), dependency);
        blocked? := #t;
      end;
    end;
    if (blocked?)
      work-switch-state(work, blocked:);
    end;
  end;
end method;

define method work-add-dependent (work :: <blocking-work>, other :: <blocking-work>)
 => (added? :: <boolean>);
  with-lock (work-lock(work))
    if (work-finished?(work))
      #f
    else
      work-dependents(work) := add!(work-dependents(work), work);
      #t;
    end;
  end;
end method;

define method work-finished-dependency (work :: <blocking-work>, dependency :: <blocking-work>)
 => ();
  with-lock (work-finish-lock(work))
    work-unfinished-dependencies(work) := remove!(work-unfinished-dependencies(work), dependency);
    if (empty?(work-unfinished-dependencies(work)))
      %work-switch-state(work, ready:);
    end;
  end;
end method;

define method work-finish (work :: <blocking-work>)
  => ();
  with-lock (work-lock(work))
    next-method();
    for (dependent :: <blocking-work> in work-dependents(work))
    %work-switch-state(work, finished:);
      work-finished-dependency(dependent, work);
    end;
  end;
end method;
