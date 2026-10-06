---
name: supervise-review-stream
description: As a supervisor, re-run a stream's stated claims over a wider set of files (all of origin/main and the other streams' branches) to see whether they still hold before the stream opens its PR. Claim verification, not a code review. Use when the user types /supervise-review-stream [stream], when a review-request is picked up from the mailbox, or when a stream seems to have opened or be about to open a PR without asking for review.
argument-hint: "[stream-id or ticket]"
---

# Supervise: review stream

Check whether a stream's claims hold when you widen the view beyond what the stream could see.

This is **not a code review.** Don't comment on design, naming, style or approach. The question is only: *is what the stream says true, across the whole scope?*

First, read `conventions.md` and `process-style.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read them in this session.

**Guard.** Supervisors only, and only for streams on your own board.

**Argument:** `$ARGUMENTS` is the stream id or ticket, if given.

**Which review to run:**
- **A specific stream was given:** use its newest request, either the one just picked up or the one listed under the board's **Pending reviews**.
- **No argument:** take the oldest entry in **Pending reviews**. If there are several, list them and say which one you're starting. If the list is empty, ask which stream to review.
- **No request exists for the stream:** this command stays available for the user to type by hand (process style S3). That's the backstop for when no request was sent. Build the claim list yourself from the brief, the ticket and the branch diff, and say in the result that no request existed.

Usually this runs automatically, because the mail watcher picked up a `review-request` and `/supervise-check-mail` started it (or queued it, if the user was busy).

## Steps

1. **Pin the target.** `git fetch origin`. Check that the branch head matches the SHA in the request. If the stream has moved on since, review the new head and say so.
2. **Recompute the facts yourself.** Get the changed files and sections from `git diff origin/main...<branch>`. Compare them with the stream's "Changed" list. Anything missing from its list, or listed but not changed, is a finding.
3. **Re-run each claim at a wider scope.** Use read-only helper agents for several claims. Examples:
   - "Every caller updated" → `git grep` across all of `origin/main` **and** every other running stream's branch on your board. A caller that another stream is adding right now is exactly what this stream couldn't see.
   - "No change outside scope" → compare the changed sections with the brief's areas and the other streams' `observed` areas. Same section = conflict.
   - "Migration/data is safe" → look for other streams' code or tests that read or assume that data (shared-data coupling).
   - "Tests pass" → you don't run builds or tests in a stream's worktree. Check that the command covers what the claim says it covers. If it ran a narrower suite than the change touches, ask the stream to run the wider command and send the output.
   - Items from the brief's "Unverified" list → were they confirmed?
4. **Check against main's movement.** Has anything merged since the stream's base that touches the same sections? (`git diff <merge-base>..origin/main` on those files.)
5. **Classify each claim:** **held** (with your evidence), **failed** (with your evidence), or **couldn't verify** (with the reason).

## Result

Post a `review-result` to the stream (conventions §6):

```
Reviewed <branch> @ <sha> against origin/main @ <sha> and <n> other active branches.
Request: <filename> | none (manual review)

Held:     1, 3, 4
Failed:   2: <what you found, with file:line @ ref>
Couldn't verify: 5: <why; what the stream should do>
Wider-scope findings:
  - <e.g. gh-77 adds a new caller of oldFn() in api/routes.ts › register() @ <branch sha>>
```

Update the board: stream state `reviewed`, observed areas, and any new dependencies. Remove the stream's line from **Pending reviews**, and mention any reviews still left there. If a finding affects **another** stream of yours, send that stream a `correction` or `note` too. If a finding means two streams are now in conflict, tell the user and propose an order.

Tell the user in two or three lines: the verdict, and what the stream should do next.
