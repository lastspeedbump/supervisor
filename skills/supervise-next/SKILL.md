---
name: supervise-next
description: Answer "what can I start now?" for a supervisor session. Checks which in-scope tickets can safely run in parallel (overlap down to file sections, shared data, other supervisors' work), what to hold back, and how to order replace-X-with-Y changes so main keeps working. Use when the user types /supervise-next or, as a supervisor, asks what to launch, what's blocked, or how to sequence the remaining tickets.
---

# Supervise: next

Decide which tickets can start now, which have to wait, and in what order the rest should go. Base the decision on the code, not on the tickets' own descriptions.

First, read `conventions.md` and `process-style.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read them in this session.

**Guard.** Supervisors only. If there's no board for this session, stop and suggest `/supervise`.

## Steps

1. **Fresh state.** If the board's Snapshot isn't from this turn, run the reorient routine first.
2. **Candidates.** All tickets in scope that aren't done and don't already have a stream.
3. **Code areas for each candidate.** Predict the files *and sections* (function, class, config block, route, migration) each ticket will touch. Base this on the ticket plus a search of `origin/main` (`git grep -n`), not the ticket's wording alone. Use read-only helper agents if there are many. Record them on the board as `predicted`, with evidence.
4. **Areas in flight.** For each running stream, get its real areas: `git diff -U0 origin/main...<branch>`. The hunk headers name the enclosing function. Mark these `observed`. Do the same for other supervisors' branches you can see (names and diffs only).
5. **Check every pair** (candidate × running stream, and candidate × candidate):
   - **Same section** (same function, block, or adjacent lines): conflict. Don't run them side by side.
   - **Same file, different sections:** usually fine. Put a note in both briefs.
   - **Shared data:** one ticket writes a data source that another's tests or code assume (seed data, fixtures, migrations, a shared test database, caches, feature flags, global config, generated files). For example, one stream starts populating a table while another stream's tests assume it's empty. Treat this as a conflict unless you can show the other side doesn't care.
   - **Logical dependency:** one needs something the other creates. Order them.
   - **Another supervisor's work** overlapping any of the above: don't resolve it yourself. Hold the ticket and tell the user (conventions §3).
6. **Staged replacements.** When a ticket, or a group of tickets, replaces X with Y, order the steps so main works after every merge:
   1. Add Y alongside X.
   2. Switch callers from X to Y (can be split across streams by area, if the areas don't conflict).
   3. Remove X, only after every caller is switched. Verify that with `git grep` on `origin/main`, not by trusting the step 2 tickets.

   If the tickets aren't split this way, say so and suggest the split. The streams (or the user) rewrite the tickets, not you (process style S1). If tickets make wrong claims about each other ("blocked by #12" when #12 is unrelated), propose the exact fix and apply it only with approval.
7. **Update the board's Plan:** running now, ready next, held back with reasons, staged replacements.

## Report

```
Ready to start (safe in parallel with everything running):
  #<n> <title>: areas <file › section>; why it's safe
Hold:
  #<n>: conflicts with <stream/ticket> in <file › section> | shared data <what> | needs #<m> first
Ordering:
  <staged replacement or dependency chain>
Needs your decision:
  <only real decisions: other supervisors' overlap, scope questions>
```

Then offer to write briefs: "Run `/supervise-fanout #<n>` for any of the ready ones."

When it's unclear whether two tickets overlap, treat them as overlapping and say why. A held ticket costs a little time. Two streams fighting over one function costs a lot more.
