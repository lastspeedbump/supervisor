# Brief: <display name>

<!-- Written by /supervise-fanout to ~/.claude/supervise/<repo>/<supervisor>/briefs/<stream-id>.md.
     Frozen once the stream posts `started`. Corrections go by mail. -->

## Who you are
- You are the stream **"<display name>"**, id `<stream-id>`.
- Your supervisor is **`<supervisor-name>`**. Its mailbox is `<state dir>/mailbox/`. That's the only mailbox you ever read or write.
- Your ticket is **#<n>**: <title>. Read it in full with the tracker's read operation before you start. The ticket, not this brief, defines what to build.
- Main repo: `<main repo path>`. Base: `origin/main` at `<short sha>` when this brief was written.

## Set up
1. Create your worktree from the main repo and work only inside it:
   ```
   git -C <main repo path> fetch origin
   git -C <main repo path> worktree add -b <branch> <worktree path> origin/main
   ```
2. Post a `started` message to the supervisor (format: `~/.claude/skills/supervise/references/conventions.md` §6). This freezes this brief. From now on, changes reach you as `correction` messages, which override the brief.
3. Start your mail watcher for `<stream-id>` on the mailbox above (conventions §6, "Watching for mail"). Keep it running until cleanup, so answers and corrections reach you without a nudge.
4. Read the ticket and the facts below, then tell the user your plan in a few lines and confirm it with them before writing code.

## Verified facts
<!-- Each fact checked against origin/main with evidence. Only what the stream needs. -->
- <fact> (`<file>:<line>` @ origin/main `<sha>`)

## Unverified: confirm before relying on these
- <claim from the ticket or elsewhere that couldn't be checked, and why>

## Other work in flight
<!-- What other streams (this supervisor's) are touching, so you can stay clear. -->
| Stream | Ticket | Areas |
|---|---|---|
| <id> | #<n> | `<file> › <section>` |

**Stay out of:** <areas>. If your ticket needs a change there, stop and send a `question`.

## Ordering
<!-- Only if this ticket is a step in a staged replacement, or depends on other work. -->
<e.g. "This is step 2 of 3 (switch callers from X to Y). Y exists on main (#a merged). Don't remove X: that's #c.">

## How you work
- **The user is in the loop.** Whenever you're unsure about intent, scope, approach or a trade-off, ask the user and wait. Don't guess and continue.
- **Ask the supervisor about facts and coordination:** what another stream is doing, whether something exists on main, whether an area is free. Post a `question`, then tell the user in one line: "Question posted to supervisor `<supervisor-name>`. It will pick this up automatically. If nothing happens, run `/supervise-check-mail` there." Carry on only with work the answer can't affect. Your watcher will tell you when the answer arrives.
- **If the supervisor answers `UNSURE` or `ASK-USER`,** ask the user, and don't proceed on that point until they answer.
- **Ask the user before anything visible outside this session:** pushing, opening a PR, commenting, or creating or editing tickets. Show the exact text.
- **If the ticket needs rewriting, splitting or a follow-up,** draft it yourself and get the user's approval. You have the context for it. Tell the supervisor afterwards with a `note`.
- **Stay in scope.** Do what the ticket asks. Anything else you notice becomes a `note` to the supervisor or a follow-up ticket, not a change on this branch.
- **Handle mail the moment your watcher reports it.** Finish the current step, run `/supervise-check-mail`, then carry on, without asking the user whether to. A correction or answer may change what you're about to do. Also check mail by hand before asking for review and before opening a PR, in case the watcher stopped.

## Finishing
1. When the work is done and tests pass locally, run `/supervise-request-review`. Wait for the `review-result`.
2. Act on the result. If claims failed, fix them and request review again.
3. With the user's approval of the exact title and body, push and open the PR. Post `pr-opened` with the number.
4. The user merges. Nothing in this process merges for them. When the PR merges, post `pr-merged`. If it's closed without merging, post `pr-closed` and ask the user what next.
5. After the merge, the user runs `/supervise-cleanup` in this session to remove your worktree and branch.
