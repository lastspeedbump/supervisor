---
name: supervise-finalize
description: Close out a supervisor's run. Confirms every in-scope ticket is resolved, compares the original scope with what actually shipped, cleans up leftover worktrees and branches of this supervisor's streams (with approval), saves the mistake log, and deletes the supervisor's board and mailbox. Use only when the user types /supervise-finalize in a supervisor session.
disable-model-invocation: true
---

# Supervise: finalize

End this supervisor's run and leave nothing behind but the shipped work and the lessons.

First, read `conventions.md` and `process-style.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read them in this session.

**Guard.** Supervisors only. Everything here applies to **this supervisor's** board and streams. Other supervisors' worktrees, branches and state are never touched, even if they look abandoned (conventions §3).

Work through the steps in order, and stop wherever the user needs to decide something.

## 1. Last look

- Run the reorient routine and the check-mail routine. Handle or explicitly set aside every unhandled message.
- If **Pending reviews** on the board isn't empty, list those reviews, and ask whether to run them first or drop them.
- If a stream is still mid-work (`started`, `review-requested`, `pr-open`), say so. Ask whether to wait, or to finalize anyway and treat it as abandoned.

## 2. Every ticket resolved

For every ticket in the board's Scope (original plus approved changes), observe its state with the tracker, and put each one in one bucket:
- **Shipped:** closed by a merged PR (name the PR).
- **Closed without shipping:** say why, if it's recorded anywhere.
- **Still open:** the user decides whether to defer it, re-scope it, or keep going. Don't close tickets yourself. Any tracker change needs approval of the exact text.

## 3. Scope versus shipped

Compare the Scope section, which was frozen at the start, with what merged:
- Scope items that shipped as planned.
- Scope items that shipped differently, or partly.
- Things that shipped but weren't in the original scope (list each one's PR and how it got in).
- Follow-ups created by streams during the run.

Verify against `origin/main` with evidence for anything you claim shipped. Don't rely on the board alone.

## 4. Leftover streams

For each stream on the board that isn't `cleaned-up`, observe:

| Stream | Worktree exists? | Uncommitted? | Unpushed commits? | PR state | Remote branch? |
|---|---|---|---|---|---|

Use `git worktree list`, `git -C <worktree> status --porcelain`, `git -C <worktree> log --oneline @{u}..` (or against the PR head), the tracker's `read-pr`, and `git ls-remote --heads origin <branch>`.

Also look for worktrees and local branches under this supervisor's prefix (`<supervisor>/...`) that aren't on the board. Those come from mistakes, so log them.

Then propose removals **one stream at a time**, with exact commands:
- **Merged with nothing extra:** the same commands as `/supervise-cleanup`. One approval can cover the batch, if the user says so.
- **Uncommitted work or unpushed commits:** show what would be lost (the file list and commit subjects). Remove only on explicit approval for that specific stream. Suggest pushing or saving it first.
- **Remote branches:** ask separately.
- **Open sessions:** you can't close another session. Tell the user which stream sessions to close.

Never use `--force` on a worktree without explicit approval for that specific worktree.

## 5. Keep the lessons

Append the board's **Mistake log** to `~/.claude/supervise/lessons.md` (create it if it doesn't exist), under a heading `## <date>: <repo>/<supervisor>`. Leave the entries unedited.

If a mistake happened more than once, or cost real time, suggest wording for a new process-style rule (see `process-style.md`, "How rules get here"). The user decides whether to add it.

## 6. Report

Give the user the final report in chat: tickets by bucket, scope versus shipped, what was cleaned up, what was left and why, and the lessons saved. If they want it posted somewhere (a ticket, a PR, a doc), draft it and get approval of the exact text.

## 7. Delete the state directory

Last of all, once the user confirms: stop your mail watcher, then delete `~/.claude/supervise/<repo>/<supervisor>/` (board, briefs, mailbox). If no other supervisors are left under `~/.claude/supervise/<repo>/`, delete that empty folder as well. Leave `lessons.md` and the repo profile in place.

Tell the user that this supervisor is finished and the session can be closed.
