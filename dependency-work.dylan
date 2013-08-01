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
  // dependencies are immutable, so no need to lock
  let dependencies = work-dependencies(work);
  // set up dependencies
  with-lock (work-lock(work))
    let blocked? = #f;
    for (dependency :: <dependency-work> in dependencies)
      if (%work-add-dependent(dependency, work))
        %work-add-dependency(work, dependency);
        blocked? := #t;
      end;
      if (blocked?)
        %work-switch-state(work, blocked:);
      end;
    end;
  end;
end method;

define method %work-add-dependency (work :: <dependency-work>, dependency :: <dependency-work>)
  work-unfinished-dependencies(work) := add!(work-unfinished-dependencies(work), dependency);
end method;

define method %work-add-dependent (work :: <dependency-work>, dependent :: <dependency-work>)
 => (added? :: <boolean>);
  with-lock (work-lock(work))
    if (work-finished?(work))
      #f
    else
      work-dependents(work) := add!(work-dependents(work), dependent);
      #t;
    end;
  end;
end method;

define method %work-finished-dependency (work :: <dependency-work>, dependency :: <dependency-work>)
 => ();
  with-lock (work-lock(work))
    // remove dependency from unfinished list
    work-unfinished-dependencies(work) := remove!(work-unfinished-dependencies(work), dependency);
    // switch to ready state when all dependencies are done
    if (empty?(work-unfinished-dependencies(work)))
      %work-switch-state(work, ready:);
    end;
  end;
end method;

define method %work-finished (work :: <dependency-work>)
  => ();
  // we need to lock for the state change
  with-lock (work-lock(work))
    %work-switch-state(work, finished:);
  end;
  // safe because no dependents can be added in finished state
  let dependents = work-dependents(work);
  // unblock dependents
  for (dependent in dependents)
    %work-finished-dependency(dependent, work);
  end;
end method;
