---
name: supervise-reorient
description: Re-check git and the issue tracker from scratch and report what changed since the last snapshot. For a supervisor session (or a stream session under one) that has been idle, was compacted, or suspects its notes are stale. Use when the user types /supervise-reorient, or at the start of a supervisor or stream turn after a gap. Only applies inside an active supervise session.
---

# Supervise: reorient

Notes go stale while you aren't looking. This command replaces what you *remember* with what you can *observe*, and tells the user what moved.

First, read `conventions.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read it in this session.

**Guard.** Work out your role: a supervisor has a `board.md`, and a stream has a brief and a launch line. If you're neither, say that this command only works inside a supervise session, and stop.

## As a supervisor

1. **Fetch:** `git fetch origin --prune`. Record the new `origin/main` short SHA.
2. **Main:** `git log --oneline <old snapshot sha>..origin/main`. Which merges landed? Map each to a ticket or stream where you can.
3. **Branches and worktrees:** `git worktree list` and `git branch -r`. For each stream on the board, does its branch exist locally and on the remote? Does its worktree exist? What's its latest commit?
4. **PRs:** the tracker's `list-prs`, then `read-pr` for each PR on the board. Note state changes (opened, merged, closed, checks).
5. **Tickets:** `read-ticket` for every ticket in scope. Note state changes, new comments, and changed links between tickets.
6. **Other supervisors:** list the names under `~/.claude/supervise/<repo>/` (names only), and look for remote branches or worktrees under other supervisors' prefixes. Note any whose changed files overlap your streams' code areas (`git diff --name-only origin/main...<their branch>`). Don't open their state (conventions §3).
7. **Mail:** count unhandled messages addressed to you. Don't handle them here.
8. **Compare with the board.** Look for every place where the board says one thing and observation says another. For example: board says `pr-open` but the PR merged; a stream says "started" but there's no worktree; a code area is `predicted` but the stream's diff touches something else.
9. **Update the board:** replace the Snapshot, update each stream's fields and labels to `observed` with today's date, and log on the board any mistakes of yours that this exposed.

**Report** in this shape. Leave out empty sections:

```
Reorient: <supervisor> @ origin/main <sha> (was <old sha>)
Landed on main: ...
PRs: ...
Tickets: ...
Board was wrong about: ...   ← most important
Other supervisors touching our areas: ...
Unread mail: <n>
Suggested next: ...
```

## As a stream

1. `git fetch origin`. How far is `origin/main` ahead of your branch's base? Did anything land in files you've changed (`git diff --name-only <merge-base>..origin/main` intersected with your own changed files)?
2. Your PR's state, if you have one.
3. Your ticket's state and new comments.
4. Unhandled mail addressed to you (run `/supervise-check-mail` to handle it).
5. Tell the user in a few lines. If main moved in your files, ask them before rebasing or merging.
