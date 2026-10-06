---
name: supervise-request-review
description: For a stream session working under a supervisor, package finished work for verification before opening a PR. Gets the changed files from git rather than memory, and pairs every claim with the command that proves it, then posts a review request to the supervisor's mailbox. Use when the user types /supervise-request-review, or when a stream has finished its ticket and is about to push or open a PR.
---

# Supervise: request review

Before you open a PR, give your supervisor everything it needs to check your work over a wider scope than you can see.

First, read `conventions.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read it in this session.

**Guard.** Streams only. You need a brief, and you need to be in your own worktree. If you're not a stream, say so and stop.

## Build the package from git, not memory

Your memory of what you changed is the least reliable source available. Collect it fresh:

1. `git fetch origin`
2. `git status --porcelain`. If anything is uncommitted, ask the user whether to commit it first. Review covers commits only.
3. Changed files: `git diff --name-only origin/main...HEAD`
4. Sections changed: `git diff -U0 origin/main...HEAD` (the hunk headers name functions). Summarise these as `file › section`.
5. Commits: `git log --oneline origin/main..HEAD`
6. Head SHA: `git rev-parse --short HEAD`

## Claims, each with its proof

List what you're asserting about your change. Each claim gets the exact command that demonstrates it, and the result you got **when you ran it just now**. Don't rely on an earlier run. Typical claims:

- **Tests pass:** the exact test command and its summary line.
- **Every caller was updated:** `git grep -n <old name>` and its (empty) output.
- **Behaviour is unchanged outside the ticket:** which tests cover it, and the command.
- **No changes outside the ticket's scope:** the changed-file list above, with one line per file saying why it changed.
- **A migration, schema or data change is safe** for other code: the command that shows it.
- Anything the brief's "Unverified" list asked you to confirm, and what you found.

If you can't prove a claim with a command, list it under **Not proven** and say why. Don't drop it, and don't dress it up.

## Post it

Write a `review-request` message to your supervisor (conventions §6):

```markdown
---
from: <stream-id>
to: <supervisor>
type: review-request
ticket: "#<n>"
sent: <UTC>
---
Branch: <branch> @ <head sha>   Base: origin/main @ <sha>
Worktree: <path>

## Changed
- <file> › <section>: <why>

## Claims
1. <claim>
   Command: `<command>`
   Result: <summary line or short output>

## Not proven
- <claim>: <why>

## Notes for the supervisor
- <things you suspect may affect other streams>
```

Make sure your mail watcher is running (conventions §6, "Watching for mail"), and arm it if it isn't, so the result reaches you without a nudge.

Then tell the user: "Review requested from supervisor `<name>`. It will pick this up automatically. If nothing happens, run `/supervise-check-mail` in the supervisor session." If the watcher can't run in this client, say only the nudge part.

Wait for the `review-result`. A `review-queued` reply means the supervisor will get to it later, so keep waiting. Don't open the PR before the result arrives unless the user tells you to.

## After the result

The result lists each claim as **held**, **failed** or **couldn't verify**, along with anything found in the wider scope.
- **Failed:** fix it (or discuss it with the user), then request review again with a new head SHA.
- **Couldn't verify:** show the user and let them decide.
- **All held:** draft the PR title and body (following the profile's PR rules, linking the ticket), get the user's approval of the exact text, push, open the PR, and post `pr-opened`.
