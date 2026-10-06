# Supervisor

A set of Claude Code skills for running several coding agents in parallel without them stepping on each other.

One Claude session is the **supervisor**. It plans, tracks and verifies the work, and never writes code. Each piece of implementation goes to a separate **stream**: a session that handles one ticket in its own git worktree and reports back through a local mailbox.

> A supervisor's value is independent scope, not intelligence. It runs the same commands as the streams, over more ground.

## Why

When several agents work at once, they fail in the same ways every time, and none of them can see it happening:

- **A stream can't see the other streams.** Two of them change the same function, or one removes something another just started using.
- **The supervisor can't see what a stream actually ran.** "Tests pass" and "I updated every caller" arrive as claims, not evidence.
- **Everyone trusts old notes.** Things written down an hour ago get treated as true now.

Supervisor deals with this by sticking to a few rules: it verifies claims against `origin/main` with `file:line` evidence, labels every fact by how it was learned, and routes every outside action through the user.

## The supervisor's hard rules

1. **Hand off all code.** The supervisor never edits source or tests. Every change becomes a brief or prompt for a stream.
2. **Ask before anything outside the session.** PRs, comments, tickets and merges need the user's approval of the exact wording.
3. **Check claims before acting on them.** Read-only helpers verify against `origin/main` and report evidence.
4. **Stay in the role.** When implementation comes up, the output is a prompt, never a diff.

## Commands

| Command | Run by | Purpose |
|---|---|---|
| `/supervise [name]` | supervisor | Start or resume the supervisor role: board, mailbox, routine |
| `/supervise-reorient` | either | Re-check git and the tracker, and report what changed |
| `/supervise-next` | supervisor | What can start now, what to hold back, and in what order |
| `/supervise-fanout <ticket>` | supervisor | Write a verified brief and a launch line for one stream |
| `/supervise-check-mail` | either | Handle messages addressed to you |
| `/supervise-request-review` | stream | Package finished work, with each claim paired with the command that proves it |
| `/supervise-review-stream [stream]` | supervisor | Re-run a stream's claims over a wider scope (not a code review). With no argument, runs the oldest queued review |
| `/supervise-cleanup` | stream | Remove its own worktree and branch, only after the PR has merged |
| `/supervise-finalize` | supervisor | Scope vs shipped, leftover cleanup, delete the board and mailbox |

`/supervise`, `/supervise-fanout`, `/supervise-cleanup` and `/supervise-finalize` run only when you type them, because they create state, start work or delete things. Claude can run the others on its own when the situation calls for it, inside a supervise session.

### Automatic mail pickup

Each supervisor and stream runs a small background watcher, [`watch-mail.sh`](skills/supervise/scripts/watch-mail.sh), which wakes its session when mail addressed to it arrives. In Claude Code this uses the `Monitor` tool.

Mail is handled straight away, in both directions, even in the middle of other work. The session finishes its current step, handles the message, tells you in one line, and carries on. It doesn't ask first, because an answer or correction can change what the other side is doing right now.

The one exception is review requests, because a review takes a while. If the supervisor is idle, it starts the review straight away. If you're in the middle of something with it, it asks:

> I see stream "implement ticket #1234" has requested a review. Do you want me to start that now, or later via `/supervise-review-stream`?

If you choose "later", the review is queued on the board, and the stream is told to keep waiting. Run `/supervise-review-stream` when you're ready. In clients without background watching, everything still works, but you nudge sessions with `/supervise-check-mail`.

## How a run goes

1. In your repo's main checkout, start a session and run `/supervise auth-rework`. The first time in a repo, it asks a few questions and saves a profile.
2. Give it the scope: a goal, plus tickets (a label, milestone or list).
3. `/supervise-next` shows what can run side by side.
4. `/supervise-fanout #123` writes a brief and gives you a launch line. Paste the line into a new session. The stream names itself, creates its worktree, and checks its plan with you.
5. Streams ask the supervisor factual questions through the mailbox, and ask *you* about decisions. When a stream finishes, it requests review, and the supervisor picks the request up automatically. The supervisor re-checks its claims across all of main and the other streams, and only then does the stream open a PR, with your approval.
6. You merge. The stream runs `/supervise-cleanup`.
7. When the scope is done, `/supervise-finalize` reports, cleans up, and deletes the supervisor's state.

## Where things live

```
~/.claude/supervise/
├── lessons.md                      mistake logs from finished runs (kept)
└── <repo>/<supervisor>/            one per running supervisor; deleted by finalize
    ├── board.md                    tracking board
    ├── briefs/<stream-id>.md       one per stream, frozen once started
    └── mailbox/ (+ done/)          messages between supervisor and its streams
```

Nothing is written inside your repositories. Several supervisors can run in one repo. Each one sees only its own state and its own streams, and learns about the others only through git and the tracker.

## Design notes

- **Truth labels.** Every fact on the board is `observed` (checked, with date and command), `reported` (someone said so), or `not recorded`.
- **Overlap is checked by section, not just by file:** two streams editing different functions in one file is fine, and two editing the same function isn't. Shared data counts too, for example one stream seeding a table that another stream's tests expect to be empty.
- **Replacements keep main working:** add Y, switch to Y, then remove X, with one merge per step.
- **Briefs are frozen once a stream starts.** Corrections go through the mailbox.
- **Process style:** opinionated rules learned from real runs live in [`skills/supervise/references/process-style.md`](skills/supervise/references/process-style.md). Mistake logs flow into `~/.claude/supervise/lessons.md`, and recurring lessons become new rules.

## Install

Requirements: git (with worktrees), bash for the mail watcher (Git Bash on Windows), Claude Code, an issue tracker the agent can read (GitHub through the [`gh` CLI](https://cli.github.com/) is built in), and you, launching each stream session by hand.

Copy the skill folders into your personal skills directory:

```bash
cp -r skills/supervise* ~/.claude/skills/
```

On Windows (PowerShell):

```powershell
Copy-Item -Recurse skills\supervise* $HOME\.claude\skills\
```

Each skill is a `SKILL.md` file, with shared reference files in `supervise/references/` and the mail watcher in `supervise/scripts/`. There's nothing to build.

## Other trackers

Tracker commands are kept in one file, [`skills/supervise/references/trackers.md`](skills/supervise/references/trackers.md). GitHub is fully described there. To add Linear, Jira or another tracker, add a section mapping each operation to a command or MCP tool, and set `tracker:` in the repo profile.

## What it isn't

- **Not a code review.** It checks whether claims hold, not whether the design is good.
- **Not a merge bot.** Nothing here merges a PR or pushes to `main`.
- **Not autonomous.** Every action visible outside a session waits for your approval.
