# Creating a repo profile

Run this when `/supervise` finds no `profiles/<repo>.md`. Copy `profiles/example.md` and fill it in.

1. **Fill in what you can observe first,** and label those values `[observed]`:
   - `<repo>` and owner, from `git remote get-url origin`
   - Default branch, from `git symbolic-ref refs/remotes/origin/HEAD` (fall back to `main`)
   - Tracker: if the remote is on github.com, propose `github`, and check `gh auth status`
   - PR template: `.github/pull_request_template.md` or similar
   - Test/build commands: `package.json` scripts, `Makefile`, `pyproject.toml`, CI workflow files
   - Existing branch naming: `git branch -r` (look for a pattern)
2. **Ask the user only about what you couldn't observe,** in one batch, offering the default for each:
   - Which tracker, if not GitHub? How do tickets get grouped into a scope (label, milestone, project, epic)?
   - PR process: draft first? Required reviewers? Does the PR body have to link the ticket (`Closes #n`)?
   - Branch naming, if the team requires one. Default: `<supervisor>/<stream-id>-<slug>`.
   - Worktree root. Default: a sibling folder, `<main repo parent>/<repo>-worktrees/`.
   - Areas streams should never touch without asking (generated code, migrations, vendored code, CI config).
   - Anything else a new contributor would need to be told.
3. Show the finished profile, save it on approval, and say that it's git-ignored and stays on this machine.
4. If the profile names a tracker that `trackers.md` doesn't cover, tell the user. Offer to draft that tracker's section, or to run with tracker operations done by hand (the supervisor asks the user to paste ticket contents).
