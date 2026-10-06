# Process style

Rules learned from running supervisors on real work. Each one exists because ignoring it caused a problem. They're opinions, held on purpose. When a rule seems to get in the way, follow it anyway and tell the user what you would have done instead. If they agree, the rule changes here, not in the moment.

## How rules get here

1. A supervisor makes a mistake and logs it on its board.
2. `/supervise-finalize` copies the mistake log to `~/.claude/supervise/lessons.md`.
3. When a lesson recurs or costs real time, the user turns it into a rule below, in the same shape: the rule, why it exists, and where it applies.

Keep rules about *process*: who does what, when, and through which channel. Coding-style rules belong in the repo, not here.

---

## S1. Don't take ticket-writing back from streams

**Rule.** When a ticket needs writing, rewriting, splitting or a follow-up, the stream working nearest to it does that (with its user's approval). The supervisor only fixes the claims tickets make *about each other*: dependencies, "blocked by", "duplicates", ordering.

**Why.** The stream has read the code and the conversation behind the ticket, and the supervisor has a summary. A supervisor-written ticket is confidently wrong in the places that matter.

**Applies to.** `/supervise-next`, `/supervise-fanout`, `/supervise-check-mail`.

## S2. Don't edit a brief after its stream has started, even to fix it

**Rule.** After a stream posts `started`, its brief is frozen. Put every correction in a `correction` message.

**Why.** The stream read the brief once and is now working from its own understanding. It won't re-read a changed file, but it does check mail. A silent edit also destroys the record of what the stream was actually told.

**Applies to.** `/supervise-fanout`, `/supervise-check-mail`.

## S3. Keep `/supervise-review-stream` invokable by humans

**Rule.** Normally `/supervise-review-stream` runs because a stream's `review-request` arrived. It must also stay available as a command the user can type, even though they rarely will.

**Why.** It's the backstop for when the automatic request never fired: the stream forgot, ran out of context, or opened a PR directly.

**Applies to.** `/supervise-review-stream`. When run by hand with no request message, review the stream's branch directly, and note that no request existed.

## S4. Don't relay a stream's question to the user, even if you've worked out the answer

**Rule.** When a stream's question is a decision for the user, reply `ASK-USER` and let the stream ask in its own session. Don't put the question to the user from the supervisor session, and don't pass along "the user said X".

**Why.** The stream has the context the user needs to answer well, and the answer has to land where the work happens. A relayed answer reaches the stream second-hand, as `reported`, and drops the user's caveats. You can include your findings in the `ASK-USER` reply so the stream can show them to the user.

**Applies to.** `/supervise-check-mail`, and any time a stream's question comes up in the supervisor session.

---

<!-- New rules go here. Next number: S5. -->
