# Profile: example-repo

<!-- Copy to profiles/<repo>.md. Real profiles are git-ignored; only this example is committed. -->

## Repository
- Remote: `github.com/<owner>/example-repo`
- Main branch: `main`
- Main repo path on this machine: `C:/repos/example-repo`

## Tracker
- tracker: `github`  <!-- see references/trackers.md -->
- Scope grouping: label `feature/<name>` or milestone `<name>`
- Ticket reference format: `#<n>`; stream id format `gh-<n>`

## Branches and worktrees
- Branch pattern: `<supervisor>/<stream-id>-<slug>`
- Worktree root: `C:/repos/example-repo-worktrees/<supervisor>/`

## Pull requests
- Open as draft first: yes
- Body must include: `Closes #<n>`, a summary, and a test plan
- Template: `.github/pull_request_template.md`
- Required reviewers: none set by the stream; the user assigns
- Merging: always done by the user

## Commands
- Install: `npm ci`
- Test (all): `npm test`
- Test (one file): `npm test -- <path>`
- Lint/typecheck: `npm run lint && npm run typecheck`

## Ask before touching
- `migrations/`: ordering matters across streams
- `src/generated/`: regenerate, never hand-edit
- `.github/workflows/`

## Notes
- Integration tests share a single local database; streams that seed data can break each other's "empty table" assumptions.
