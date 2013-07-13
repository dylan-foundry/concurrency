module: concurrency
synopsis: Work items with dependencies.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: See accompanying file LICENSE

define class <dependency-work> (<locked-work>)
  // other items this work depends on
  // immutability intended to discourage cycles
  constant slot work-dependencies :: <list> = #(),
    init-keyword: dependencies:;

  // items that depend on this work being done
  slot work-dependents :: <list> = #();

  // dependencies not yet finished
  slot work-unfinished-dependencies :: <list> = #();
end class;

define method initialize (work :: <dependency-work>, #rest keys, #key, #all-keys)
 => ();
  next-method();
  // we need to take our lock because dependencies
  // may well be active already and call us back
  with-lock (work-lock(work))
    let blocked? :: <boolean> = #f;
    for (dependency :: <dependency-work> in work-dependencies(work))
      if (work-add-dependent(dependency, work))
        work-unfinished-dependencies(work) := add!(work-unfinished-dependencies(work), dependency);
        blocked? := #t;
      end;
    end;
    if (blocked?)
      %work-switch-state(work, blocked:);
    end;
  end;
end method;

define method work-add-dependent (work :: <dependency-work>, other :: <dependency-work>)
 => (added? :: <boolean>);
  with-lock (work-lock(work))
    if (work-finished?(work))
      #f
    else
      work-dependents(work) := add!(work-dependents(work), other);
      #t;
    end;
  end;
end method;

define method work-finished-dependency (work :: <dependency-work>, dependency :: <dependency-work>)
 => ();
  with-lock (work-lock(work))
    work-unfinished-dependencies(work) := remove!(work-unfinished-dependencies(work), dependency);
    if (empty?(work-unfinished-dependencies(work)))
      %work-switch-state(work, ready:);
    end;
  end;
end method;

define method %work-finished (work :: <dependency-work>)
  => ();
  with-lock (work-lock(work))
    %work-switch-state(work, finished:);
    for (dependent in work-dependents(work))
      work-finished-dependency(dependent, work);
    end;
  end;
end method;
