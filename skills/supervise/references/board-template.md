# Board: <supervisor-name>

<!-- Copy this template to ~/.claude/supervise/<repo>/<supervisor>/board.md and fill it in.
     Every fact carries a truth label: [observed <date> · <how>], [reported <date> · <who>], [not recorded]. -->

## Identity
- Supervisor: `<supervisor-name>`
- Repo: `<owner>/<repo>`, main repo path `<absolute path>`
- State directory: `~/.claude/supervise/<repo>/<supervisor-name>/`
- Profile: `profiles/<repo>.md`
- Started: <date>

## Scope
<!-- Written at start. Never rewritten: /supervise-finalize compares against it. -->
**Goal:** <the user's description of the work>

**Tickets at start:**
| Ticket | Title | State at start |
|---|---|---|
| #<n> | <title> | <open/closed> [observed <date> · tracker] |

**Scope changes** (append only):
- <date>: <added/removed #n>, <why>, approved by user

## Snapshot
<!-- Replaced on each /supervise-reorient. -->
- Taken: <UTC timestamp>
- origin/main: `<short sha>`
- Open PRs in scope: <#n (branch), ...>
- Ticket states: <#n open, #m closed, ...>
- Other supervisors seen (branch prefixes only): <names or none>

## Streams

### <stream-id>: <display name>
- Ticket: #<n>
- State: <planned | briefed | started | review-requested | reviewed | pr-open | merged | cleaned-up | pr-closed | abandoned> [label]
- Branch: `<supervisor>/<stream-id>-<slug>` [label]
- Worktree: `<path>` [label]
- PR: #<n> / none [label]
- Depends on: <stream ids or tickets, and why> [label]
- Code areas:
  - `<file> › <function/section>` (predicted | observed) [label]
- Brief: `briefs/<stream-id>.md`, frozen since <date of `started`> / not yet started
- Corrections sent: <mail filenames>
- Notes: <anything else, labelled>

## Pending reviews
<!-- Review requests the user chose to run later. Oldest first. Remove a line when its review-result is sent. -->
- <stream-id>: request `mailbox/done/<filename>`, head `<sha>`, queued <date>

## Plan
- **Running now:** <stream ids>
- **Ready next:** <tickets>
- **Held back:** <ticket>: <reason> (e.g. same section as gh-12 in `x.ts › parse()`)
- **Staged replacements:** <X → Y: 1. add Y (#a) → 2. switch callers (#b) → 3. remove X (#c)>

## Mistake log
<!-- Append only. Never edit or prune. One line each. -->
- <date>: <what I did>. <what was wrong>. <how it was caught>.
