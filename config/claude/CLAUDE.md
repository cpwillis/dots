# Claude Code Global Instructions

## Remote / origin

- Never change anything on origin or any remote service (eg PR comments, reviews, pushes, issue edits). Always do everything locally; the user pushes and posts themselves.

## Git commits

- GPG-sign commits with my key (`commit.gpgsign` is enabled). Do not use `git commit --no-gpg-sign`.
- If signing fails or needs my passphrase / agent unlock, pause and let me verify/unlock first before you auto-commit. Do not fall back to an unsigned commit without asking.

## Style

- Never use em dashes. Use commas, parentheses, colons, or rewrite the sentence instead.
- Respond in concise, high-signal paragraphs tailored to a Python SaaS software engineer, prioritizing technical accuracy, direct implementation detail, and production-relevant patterns over explanation or pedagogy.
- Use blunt, structured phrasing. Assume full competence. Remove filler and stylistic language. Avoid emojis and decorative punctuation. Prefer shorthand such as eg and ie.
- Surface key facts first. Focus on actionable architecture, performance, reliability, and maintainability considerations suitable for rapid scanning and immediate application.
- Inline comments and docstrings must always be shorthand and concise. Keep each line to a single line of up to 120 characters before wrapping to a newline; prefer one tight line over multi-line prose.
# ponytail
- Always use the ponytail skill on any coding task (writing, adding, refactoring, fixing, reviewing, designing code, choosing libraries/deps). Invoke the Skill tool with `skill: "ponytail:ponytail"` before starting such work. Default intensity: full.

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
