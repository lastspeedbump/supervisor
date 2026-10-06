# Tracker operations

Skills refer to tracker operations by name. This file maps each name to real commands for each supported tracker. The repo's profile chooses the tracker (`tracker:` field).

Reading is always allowed. Every **write** operation is visible outside the session, so show the exact text or command and get the user's approval first (see conventions §10).

## Operations every tracker must define

| Operation | Read/Write | Purpose |
|---|---|---|
| `read-ticket <id>` | read | Title, body, state, labels, links, comments |
| `list-tickets <filter>` | read | Tickets in scope (by label, milestone, project, search) |
| `ticket-links <id>` | read | Blocked-by / blocks / parent / duplicates |
| `list-prs` | read | Open PRs, with head branch and linked tickets |
| `read-pr <n>` | read | State, merged?, head SHA, base, checks, linked tickets |
| `comment <id> <text>` | write | Comment on a ticket or PR |
| `create-ticket <title> <body>` | write | New ticket (normally done by a stream, not the supervisor) |
| `edit-links <id> <change>` | write | Fix a claim one ticket makes about another |
| `open-pr <branch> <title> <body>` | write | Done by a stream, with the user's approval |

## GitHub (`tracker: github`)

Needs the GitHub CLI (`gh`), signed in (`gh auth status`). Pass `--repo <owner>/<repo>` when running from outside the repo.

| Operation | Command |
|---|---|
| `read-ticket` | `gh issue view <n> --json number,title,body,state,labels,assignees,milestone,comments,url` |
| `list-tickets` | `gh issue list --state all --limit 200 --json number,title,state,labels,milestone --label <label>` (or `--milestone`, or `--search "<query>"`) |
| `ticket-links` | Read the body and comments for "blocked by #n", "depends on #n", "closes #n" and task lists. Also check `gh issue view <n> --json closedByPullRequestsReferences` |
| `list-prs` | `gh pr list --state open --json number,title,headRefName,baseRefName,isDraft,url` |
| `read-pr` | `gh pr view <n> --json number,state,mergedAt,mergeCommit,headRefName,headRefOid,baseRefName,isDraft,statusCheckRollup,closingIssuesReferences,url` |
| `comment` | `gh issue comment <n> --body-file <file>` / `gh pr comment <n> --body-file <file>` |
| `create-ticket` | `gh issue create --title "<title>" --body-file <file> [--label ...]` |
| `edit-links` | Edit the body with `gh issue edit <n> --body-file <file>` (show the diff of the body first), or add a comment |
| `open-pr` | `gh pr create --base main --head <branch> --title "<title>" --body-file <file> [--draft]` |

Notes:
- A PR is merged only when `read-pr` reports `state: MERGED`. A squash or rebase merge leaves the branch looking unmerged to `git branch --merged`, so never use that as evidence.
- Use `--body-file` for any multi-line text, so shell quoting can't change what the user approved.
- If GitHub Projects are in use, `gh project item-list` can list scope, which needs the `project` token scope.

## Adding another tracker

Copy the GitHub section, rename it (`tracker: linear`, `tracker: jira`, ...), and fill in a command or MCP tool for every operation in the table above. If an operation is impossible, write "not supported: <what to do instead>" so skills know to ask the user rather than improvise. Nothing else in the skill set needs to change.
