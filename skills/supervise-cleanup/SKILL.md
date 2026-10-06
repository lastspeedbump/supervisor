---
name: supervise-cleanup
description: For a stream session under a supervisor, delete the stream's own git worktree and local branch after its PR has merged, and refuse if the PR hasn't actually merged. Use only when the user types /supervise-cleanup in a stream session.
disable-model-invocation: true
---

# Supervise: cleanup

Remove this stream's worktree and local branch, but only once its work is safely on `main`.

First, read `conventions.md` from the `supervise` skill's `references/` folder (normally `~/.claude/skills/supervise/references/`), unless you've already read it in this session.

**Guard.** Streams only, and only your own worktree and branch, as named in your brief. Never touch another stream's worktree or branch, or the main working tree.

## Check that it's safe. Refuse if any check fails.

1. **PR merged.** Use the tracker's `read-pr <n>`. It must report merged (on GitHub, `state: MERGED`). "Closed", "approved" and "checks green" don't count. Don't use `git branch --merged` as evidence, because squash and rebase merges defeat it.
2. **Nothing left behind.** In the worktree:
   - `git status --porcelain` is empty, or the user has looked at what's there and agreed to discard it.
   - Local HEAD equals the PR's merged head SHA (`headRefOid`). If there are local commits after it, they were never merged. List them and stop.
   - `git stash list` shows nothing from this branch, or the user agrees to drop it.

If a check fails, say exactly which one and what you saw, and stop. If the PR was closed without merging, the cleanup belongs to the user or to `/supervise-finalize`, not to this command.

## Clean up

Show the user the exact commands, then run them once they approve:

```
git -C <main repo path> worktree remove <worktree path>
git -C <main repo path> branch -D <branch>
```

- `-D` is needed because a squash-merged branch isn't an ancestor of main. That's safe here only because check 1 proved the PR merged and check 2 proved there's nothing extra.
- Run the commands against the main repo, not from inside the worktree. On Windows, removal can fail while this session's shell is inside the folder. If it does, tell the user to close this session and run the same two commands from any other terminal.
- **Remote branch:** if it still exists (`git ls-remote --heads origin <branch>`), ask the user before deleting it (`git push origin --delete <branch>`). GitHub often deletes it automatically on merge.

## Report

Post `cleaned-up` to your supervisor, listing what was removed. Stop your mail watcher. Then tell the user this session's work is done and they can close it.
