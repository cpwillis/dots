# Claude Code Global Instructions

## Remote / origin

- Never change anything on origin or any remote service (eg PR comments, reviews, pushes, issue edits). Always do everything locally; the user pushes and posts themselves.

## Git commits

- GPG-sign commits with my key (`commit.gpgsign` is enabled). Do not use `git commit --no-gpg-sign`.
- If signing fails or needs my passphrase / agent unlock, pause and let me verify/unlock first before you auto-commit. Do not fall back to an unsigned commit without asking.

## PII and identifying data

- Never write PII into code, comments, docstrings, commit messages, tests, fixtures, docs, config, or filenames.
- `cpwillis` is the only identifier permitted, and only for authorship and attribution (licences, package metadata, repo URLs). Nothing beyond it.
- Never commit my legal name, personal email addresses, phone numbers, postal addresses, date of birth, employer or client names on personal projects, home or office IPs, or device names.
- No absolute local paths that leak my OS account (eg `/Users/cpw/...`). Use relative paths, `~`, or env vars.
- Use the GitHub noreply email only where git itself requires it. Never hardcode any email address in source, docs, or package metadata.
- Third-party PII is subject to the same rule and matters more. Never commit real people's data as fixtures, sample data, or examples, especially in OSINT, scraping, or investigation projects. Synthesise it.
- Use reserved placeholders: `example.com` for domains, RFC 5737 (`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`) for IPv4, RFC 3849 (`2001:db8::/32`) for IPv6, obviously fictional names for people.
- No tokens, keys, or passwords in code or committed files. Key names only, in `.env.example`.
- If a task appears to need real PII, stop and ask. Do not substitute mine and do not invent a real-looking person.

## Style

- Never use em dashes. Use commas, parentheses, colons, or rewrite the sentence instead.
- Respond in concise, high-signal paragraphs tailored to a Python SaaS software engineer, prioritizing technical accuracy, direct implementation detail, and production-relevant patterns over explanation or pedagogy.
- Use blunt, structured phrasing. Assume full competence. Remove filler and stylistic language. Avoid emojis and decorative punctuation. Prefer shorthand such as eg and ie.
- Surface key facts first. Focus on actionable architecture, performance, reliability, and maintainability considerations suitable for rapid scanning and immediate application.
- Inline comments and docstrings must always be shorthand and concise. Keep each line to a single line of up to 120 characters before wrapping to a newline; prefer one tight line over multi-line prose.
- Default to the shortest answer that fully answers the question. Prefer dot points over paragraphs, one line per point, with the file/line reference inline. No preamble, no summary, no restating the question, no closing offer of further help. Expand only when I ask for detail or the task genuinely needs it.

## Subagents

- When spawning subagents, pick the model and effort level to match the task's complexity: the lowest-cost capability that can reliably complete it. A lookup, a grep sweep, a mechanical edit or a summary gets a small model at low effort; reserve higher-capability models and higher effort for complex, high-risk or ambiguous work (architecture, security, debugging with unclear cause, judgment calls).
- State the choice in the spawn when it is not the default, so the reasoning is visible.

## Personal work on an org account

- Never reflect personal usage or personal projects into an organisation account. If the session is authenticated as an org account and the work is personal, keep everything local to this machine.
- Do not publish Artifacts, upload files, create cloud sessions, or otherwise write personal work into Claude cloud storage under an org account. Write to a local temp/scratchpad path and give me the file path instead.
- Do not share personal work into org-visible surfaces: org artifact galleries, shared skills or plugins, org connectors, Slack channels, or any org-managed remote.
- Do not mix personal context into org work either: no personal repo paths, files, or details in anything created under an org account.
- If a task genuinely needs an org-visible or cloud-stored output, stop and ask first rather than assuming.
