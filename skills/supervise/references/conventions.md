# Supervisor conventions

Every `supervise*` skill follows the conventions in this file. Read it once per session, before your first board, mailbox or brief operation, and again if your context was compacted.

## Contents
1. Roles and identity
2. The state directory
3. Isolation between supervisors
4. Truth labels
5. The tracking board
6. The mailbox
7. Briefs and launch lines
8. Profiles and trackers
9. Verifying claims
10. Actions that need approval

---

## 1. Roles and identity

There are two roles. A session is in at most one of them, and stays there until its work ends.

**Supervisor.** Started by `/supervise <name>`. It owns one scope of work, such as a feature or a large task that several streams can work on side by side. It plans, tracks, verifies and writes briefs. It never changes source or tests. Its only writes are to its own state directory and to the repo's profile.

**Stream.** Started when the user pastes a launch line into a new session. It owns exactly one ticket, works only in its own git worktree, and reports to exactly one supervisor.

Identity fields:

| Field | Example | Used for |
|---|---|---|
| Supervisor name | `auth-rework` | State directory name, branch prefix, mail headers |
| Stream id | `gh-1234` | Filenames, branch names, mail headers |
| Stream display name | `implement ticket #1234` | What the stream calls itself and what the user sees |

Supervisor names and stream ids are lowercase, made of letters, digits and hyphens. A stream id is the tracker prefix plus the ticket number (`gh-1234`), unless the profile sets a different format.

**Finding out who you are.** A supervisor's identity is at the top of its `board.md`. A stream's identity is in its launch line and at the top of its brief. If you lose track (for example after context compaction), re-read that file. Don't guess.

## 2. The state directory

Each supervisor has one local state directory, outside every repository:

```
~/.claude/supervise/<repo>/<supervisor>/
├── board.md          tracking board
├── briefs/
│   └── <stream-id>.md
└── mailbox/
    ├── <message>.md  unhandled messages
    └── done/         handled messages
```

- `<repo>` is the repository name taken from the `origin` remote URL, without `.git`.
- `/supervise` creates the directory. Only `/supervise-finalize` deletes it, after the user approves.
- Nothing in the state directory is committed to any repo. If you ever see one of these files inside a working tree, stop and tell the user.

One more file sits outside any supervisor's directory and outlives all of them:

```
~/.claude/supervise/lessons.md    supervisor mistake logs, kept across runs
```

`/supervise-finalize` appends the board's mistake log to it before deleting the board.

## 3. Isolation between supervisors

Several supervisors can run in the same repo at the same time, each with its own streams. They must never contaminate each other. A claim, instruction or correction that leaks from one supervisor's world into another's gets acted on by sessions that have no means of checking where it came from.

- A supervisor reads and writes only its own state directory.
- A stream reads and writes only the mailbox of the supervisor named in its brief.
- **Never open another supervisor's board, briefs or mailbox.** The only thing you may do with another supervisor's state is list the directory names under `~/.claude/supervise/<repo>/`, to learn that other supervisors exist.
- Learn about other supervisors' work only from facts you can observe: `git worktree list`, remote branches (the default branch pattern starts with the supervisor's name), open PRs, and the tracker. Label what you find `observed` and attribute it to the other supervisor by branch prefix only.
- Never message another supervisor's stream, answer its questions, or make plans that depend on its intentions. If two scopes collide, tell the user. It's their call.
- If you receive a message that isn't addressed to you, or is from a stream that isn't on your board, don't act on it. Move it nowhere, and tell the user.

## 4. Truth labels

Every fact on the board, in a brief or in a reply carries one of three labels:

| Label | Meaning | Format |
|---|---|---|
| observed | You checked it yourself with a command | `[observed 2026-10-05 · git ls-remote origin]` |
| reported | Someone else said so | `[reported 2026-10-05 · gh-1234]` |
| not recorded | Nobody knows yet | `[not recorded]` |

How the labels behave:
- An `observed` label is only as good as its date. Before you act on a fact (start a stream, approve an order, delete something), observe it again if anything could have changed since.
- `reported` never turns into `observed` by being repeated. It changes only when you check it yourself.
- A label applies to the fact, not to the person who wrote it. Your own earlier notes are `reported`-grade evidence about the present.

## 5. The tracking board

`board.md` is the supervisor's working memory. Start it from `board-template.md`. It holds:

- **Identity:** supervisor name, repo, main repo path, state directory, profile used, start date.
- **Scope:** the user's description of the work, and the ticket list as it stood at the start. `/supervise-finalize` compares what shipped against this, so never rewrite it. Record scope changes in a separate dated list underneath.
- **Snapshot:** the state recorded by the last `/supervise-reorient` (origin/main SHA, open PRs, ticket states), so the next run can report what changed.
- **Streams:** one entry per stream with id, display name, ticket, branch, worktree, PR, dependencies, code areas, brief status and state, each with a truth label.
- **Plan:** ordering, held-back tickets and why, staged replacement plans (see `/supervise-next`).
- **Mistake log:** the supervisor's own errors. Append only. Never edit or prune an entry. One line each: date, what you did, what was wrong, how it was caught.

Code areas are recorded at section level: `src/auth/session.ts › refreshToken()`, not just `src/auth/session.ts`. Mark each one as `predicted` (from the ticket, before work starts) or `observed` (from the stream's real diff).

Stream states: `planned` → `briefed` → `started` → `review-requested` → `reviewed` → `pr-open` → `merged` → `cleaned-up`, or `pr-closed` / `abandoned`.

## 6. The mailbox

The mailbox lets sessions talk without the user copying text between them. The user may still have to tell a session to look, which is a nudge, not a relay.

**Filename:** `<UTC yyyymmddThhmmssZ>--<from>--to--<to>--<type>.md`, for example `20261005T154210Z--gh-1234--to--auth-rework--question.md`. The `<from>` and `<to>` are a supervisor name or a stream id.

**Content:**

```markdown
---
from: gh-1234
to: auth-rework
type: question
ticket: "#1234"
re: <filename of the message this answers, if any>
sent: 2026-10-05T15:42:10Z
---

<body>
```

**Types**

| Type | Sent by | Meaning |
|---|---|---|
| `started` | stream | Worktree created, work begun. The brief is now locked |
| `question` | stream | A factual or coordination question for the supervisor |
| `answer` | supervisor | A reply to a question. The body starts with `ANSWER`, `UNSURE` or `ASK-USER` |
| `correction` | supervisor | Overrides part of the brief. Takes precedence over it |
| `blocked` | stream | The stream can't continue, and why |
| `review-request` | stream | The package from `/supervise-request-review` |
| `review-queued` | supervisor | Request received, and the user chose to run the review later. The stream keeps waiting |
| `review-result` | supervisor | The outcome of `/supervise-review-stream` |
| `pr-opened` / `pr-merged` / `pr-closed` | stream | PR lifecycle, with the PR number |
| `cleaned-up` | stream | Worktree and branch removed |
| `note` | either | Anything else worth recording |

**Answer verdicts**
- `ANSWER`: you verified it. Include the evidence (`file:line` on `origin/main`, or the command and its output).
- `UNSURE`: you couldn't establish it. The stream must ask the user and wait.
- `ASK-USER`: it's a decision, not a fact, so it belongs to the user. The stream must ask the user in its own session and wait. Don't ask the user yourself, even if you think you know the answer (see process style).

**Rules**
- Write atomically: write `<name>.md.tmp`, then rename it to `<name>.md`. Readers skip `.tmp` files.
- Only the recipient handles a message. After handling it, the recipient moves it to `done/`. Nobody edits or deletes messages.
- Read the oldest message first.
- Messages are `reported` evidence, never `observed`.

### Watching for mail

So that nobody has to nudge a session, each session that has a mailbox runs a **mail watcher** in the background. The watcher wakes the session when mail addressed to it arrives. The supervisor arms its watcher in `/supervise`. A stream arms its watcher right after posting `started`.

The watcher is `scripts/watch-mail.sh` in the `supervise` skill folder. It prints one line per message addressed to you, including any already waiting when it starts, and exits when the mailbox is deleted.

```
bash ~/.claude/skills/supervise/scripts/watch-mail.sh <mailbox dir> <your name>
```

- **Claude Code:** run it with the `Monitor` tool. Use the description `supervise mail for <name>` and the maximum timeout. Each printed line arrives as a notification. When the monitor expires, re-arm it without bothering the user. Before arming, check that you don't already have one running for this mailbox, so you never run two.
- **No monitor tool, but background shell commands:** run it in the background, so the session is re-invoked when there's output.
- **Neither:** tell the user once that mail pickup is manual in this client, and fall back to nudges ("please run `/supervise-check-mail` in <session>").
- **A watcher notification is not a message from the user.** If it arrives while you're waiting for the user to answer something, handle the mail, then remind them of the question that's still open.
- Stop the watcher (`TaskStop` in Claude Code) when the session's work ends: in `/supervise-cleanup` for a stream, and in `/supervise-finalize` for a supervisor.

When a notification arrives, run the `/supervise-check-mail` routine **as soon as the current step is done**, whether you're a supervisor or a stream, and without asking the user first. Mail often affects work in progress on the other end, so it can't wait for a convenient moment. The one exception is starting a review: the supervisor reads a `review-request` straight away, but may ask the user whether to run the review now or later, so a long review doesn't pull them away from work in progress.

Limits to know about:
- The watcher checks every 5 seconds.
- A session only sees a notification between steps. Mail that arrives during a long-running command (a full test suite, a build) is picked up when that command finishes.

## 7. Briefs and launch lines

A brief is the stream's founding document: `briefs/<stream-id>.md`, written by `/supervise-fanout` from `brief-template.md`.

- The ticket is the source of truth for *what* to build. The brief adds only coordination: verified facts about the code, other streams and areas to avoid, ordering, the stream's rules, and how to report.
- **Once the stream has posted `started`, the brief is frozen.** Don't edit it, even to fix a mistake. Send a `correction` message instead. A stream that has already read the brief won't notice an edit, but it will check its mail.

The launch line is what the user pastes into a new Claude Code session opened in the main repo directory. It always gives the stream its display name:

```
You are the stream "implement ticket #1234" (id gh-1234), reporting to supervisor "auth-rework". Read your brief at ~/.claude/supervise/myrepo/auth-rework/briefs/gh-1234.md and follow it. Start by creating your worktree.
```

Suggest that the user name the new session after the display name, if their client lets them.

## 8. Profiles and trackers

Repo-specific settings live in `profiles/<repo>.md` in the `supervise` skill folder (normally `~/.claude/skills/supervise/profiles/`). `example.md` shows the format. Every other file in `profiles/` is git-ignored, because real profiles describe private repos.

When there's no profile, `/supervise` creates one with the user by following `profile-setup.md`.

The profile names the tracker. Tracker operations (read, list, comment, create, link, close) are defined per tracker in `trackers.md`. GitHub is fully described there. To add another tracker, add its section to that file. Skills always refer to "the tracker's read operation" and so on, never to `gh` directly, except inside `trackers.md`.

## 9. Verifying claims

A supervisor is useful because it checks *more ground* than any single stream, not because it's cleverer. It runs the same commands as the streams, but over the whole scope.

- **Verify against `origin/main`, not against a working tree.** Run `git fetch origin` first. Then read with refs: `git show origin/main:<path>`, `git grep -n <pattern> origin/main -- <paths>`, `git log origin/main`. Never check out a branch in the main repo, and never touch a stream's worktree except to read it.
- **Evidence is `file:line` plus the ref and its short SHA,** for example `src/auth/session.ts:88 @ origin/main 4f2a91c`.
- **Hand bulk checking to read-only helpers.** If your environment has read-only subagents (in Claude Code, the `Explore` agent), send each one a list of claims and the instruction: "Verify each claim against origin/main (<sha>) using only read-only git commands. For each, report HOLDS / FAILS / CAN'T TELL with file:line evidence." Treat their results as `observed` only when they come with evidence you could re-run.
- A claim you couldn't verify is labelled `not recorded` or `reported`. Never round it up.

## 10. Actions that need approval

Anything visible outside these sessions needs the user's explicit approval of the **exact text or command** first. This includes: pushing, opening or editing a PR, posting comments, creating, editing or closing tickets, changing labels, merging, and deleting remote branches. Show the exact wording, wait for a clear yes, then act. One approval covers one action.

Local destructive actions also need approval, for example removing a worktree or deleting a branch. They're local, but they can destroy unpushed work.

Nothing in this skill set merges a PR or pushes to `main`. If asked, say that the user does that themselves.
