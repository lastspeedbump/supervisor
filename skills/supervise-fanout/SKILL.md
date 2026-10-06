---
name: supervise-fanout
description: As a supervisor, write a ready-to-launch brief for one stream (one ticket, one git worktree), with every claim about the code verified against origin/main, plus the copy-paste launch line that names the stream. Use when the user types /supervise-fanout <ticket>.
argument-hint: "<ticket>"
disable-model-invocation: true
---

# Supervise: fanout

Write the brief a new stream will work from, and the launch line the user pastes to start it.

First, read `conventions.md` and `process-style.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read them in this session. The brief's shape is in `references/brief-template.md`.

**Guard.** Supervisors only. If there's no board for this session, stop and suggest `/supervise`.

**Argument:** `$ARGUMENTS` is the ticket (for example `#1234` or `1234`).

## Steps

1. **Is it safe to start?** Check the board's Plan. If `/supervise-next` hasn't cleared this ticket during this turn or a recent one, run its overlap check for this ticket now. If it conflicts with running work, say so and stop, unless the user explicitly overrides (log that on the board).
2. **Read the ticket** with the tracker's `read-ticket`, including comments and links.
3. **Collect claims.** List every statement the brief would make about the code or about other work: "function X lives in Y", "there are no other callers", "Z already exists on main", "#12 adds the column we need".
4. **Verify them** against `origin/main` (conventions §9). Use read-only helper agents if there are several. Sort them into:
   - **Verified,** with `file:line @ origin/main <sha>`.
   - **Wrong:** fix the brief's wording. If the *ticket itself* is wrong about another ticket, propose the fix to the user. If it's wrong about its own content, leave it to the stream (process style S1) and add a line to "Unverified" so the stream checks it.
   - **Can't tell:** goes under "Unverified" with the reason.
5. **Name the stream.**
   - Id: per the profile, by default `gh-<n>`.
   - Display name: a short imperative phrase the user will recognise, like `implement ticket #1234` or `fix bug #567`. Make it specific when it helps: `fix bug #567 (token refresh race)`.
   - Branch: per the profile, by default `<supervisor>/<stream-id>-<slug>`.
   - Worktree: `<worktree root>/<supervisor>/<stream-id>`.
   - Make sure the branch and worktree path don't already exist (`git branch -a --list`, `git worktree list`).
6. **Write the brief** to `<state dir>/briefs/<stream-id>.md` from the template. Keep it short:
   - Point to the ticket for *what* to build. Don't restate or rewrite the ticket.
   - Include only facts the stream needs, each with evidence.
   - List the other running streams of **this** supervisor and their areas. Never mention another supervisor's streams by name or quote their state. If they overlap, the ticket shouldn't be starting.
   - Include ordering only if it applies.
   - Keep the template's "How you work" and "Finishing" sections. They're the stream's rules.
7. **If a brief already exists for this stream,** you may edit it only while the stream hasn't posted `started`. After that it's frozen. Send a `correction` message instead (process style S2).
8. **Update the board:** add or refresh the stream entry with state `briefed`, branch, worktree, predicted areas, dependencies and brief path.

## Hand over

Give the user exactly this, ready to copy:

```
Open a new Claude Code session in <main repo path> and paste:

You are the stream "<display name>" (id <stream-id>), reporting to supervisor "<supervisor>". Read your brief at <absolute brief path> and follow it. Start by creating your worktree.
```

Add one line suggesting they name the new session "<display name>" if their client allows it. Add another line saying you'll know it has started when its `started` message arrives.
