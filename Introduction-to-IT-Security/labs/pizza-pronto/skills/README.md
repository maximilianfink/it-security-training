# Skill Battle – Security Review Skills

AI coding agents (Claude Code, Codex, Copilot, ...) can be extended with **skills**:
a folder with a `SKILL.md` file that tells the agent *when* and *how* to do a specific task.

Your job: write a skill that makes an AI agent a good **security reviewer** for the Pizza Pronto shop.

1. Copy `_template/` to a new folder named after your team, e.g. `team-margherita/`.
2. Fill in `SKILL.md`. Only text – no programming needed.
3. Create a branch and a pull request in Gitea. Another team reviews it.
4. At the end the **trainer runs every team's skill** against the shop code and compares the results.
   Have Copilot / ChatGPT / Claude yourself? Feel free to try your skill live.

**Scoring**

| | Points |
|---|---|
| Each real vulnerability found (with correct location) | +2 |
| Correct severity and a useful fix | +1 |
| False positive (reported, but not a real problem) | −1 |

> A skill can also be **malicious** – looking helpful while it steals your secrets. The trainer
> shows this as a separate demo; you don't need to build one.
