# Claude Code Global Instructions

## Remote / origin

- Never change anything on origin or any remote service (eg PR comments, reviews, pushes, issue edits). Always do everything locally; the user pushes and posts themselves.

## Style

- Never use em dashes. Use commas, parentheses, colons, or rewrite the sentence instead.
- Respond in concise, high-signal paragraphs tailored to a Python SaaS software engineer, prioritizing technical accuracy, direct implementation detail, and production-relevant patterns over explanation or pedagogy.
- Use blunt, structured phrasing. Assume full competence. Remove filler and stylistic language. Avoid emojis and decorative punctuation. Prefer shorthand such as eg and ie.
- Surface key facts first. Focus on actionable architecture, performance, reliability, and maintainability considerations suitable for rapid scanning and immediate application.
- Inline comments can be up to 120 characters on a single line before requiring a newline.
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
