# Tokoo skills + MCP

<p>
  <a href="https://www.tokoo.app"><img alt="Tokoo" src="https://img.shields.io/badge/tokoo.app-trade%20intelligence-0f766e"></a>
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-blue"></a>
</p>

Agent skills and MCP config for the **[Tokoo](https://www.tokoo.app) API**.
Tokoo finds the real importers, buyers and distributors behind customs and
shipment flows. You can filter them by HS code and country, check a company's
trade record, and unlock buyer contacts with credits.

## Quick start

**1. Get your API key.** Sign in at [www.tokoo.app](https://www.tokoo.app)
(new accounts are free), open **Settings > Developers** and create a key. It
looks like `tk_live_…` and is shown once.

**2. Give it to your agent.** Keep it out of chats and out of git:

```bash
export TOKOO_API_KEY=tk_live_...        # or put it in .env.local (gitignored)
```

**3. Install and ask.**

```bash
# Claude Code: the MCP server with your key, plus the skills
claude mcp add --transport http tokoo https://www.tokoo.app/api/mcp   --header "Authorization: Bearer $TOKOO_API_KEY"
npx skills add haijin/tokoo-skills
```

Then ask in plain words: *"Who imports HS 8504 transformers into Germany?"*
The agent picks the right skill, searches for free, and asks before it spends
any credit.

## What's inside

| Skill | Use it for |
|---|---|
| [`tokoo`](skills/tokoo/SKILL.md) | Setup, account, credits, keys, errors |
| [`find-importers`](skills/find-importers/SKILL.md) | "Who imports HS 8471 into Germany?" |
| [`find-buyers-for-my-product`](skills/find-buyers-for-my-product/SKILL.md) | "We make X. Who should we sell to abroad?" |
| [`find-distributors`](skills/find-distributors/SKILL.md) | "Distributors of industrial valves in Saudi Arabia" |
| [`check-company-trade`](skills/check-company-trade/SKILL.md) | "Does this company really import Y?" |

The full endpoint, cost and error reference is in
[`reference/api.md`](reference/api.md). Each skill also carries its own copy.

## Other ways to connect

**As a Claude Code plugin** (skills and MCP server in one; reads
`TOKOO_API_KEY` from your environment):

```bash
claude plugin marketplace add haijin/tokoo-skills
claude plugin install tokoo@tokoo
```

**One skill only:**

```bash
npx skills add haijin/tokoo-skills --skill find-importers
```

**claude.ai or ChatGPT:** add a custom connector with the URL
`https://www.tokoo.app/api/mcp` and sign in to Tokoo when asked. No key needed.

**Claude Code without a key:** run the `claude mcp add` line without
`--header`, and sign in to Tokoo in the browser when asked.

**REST, from any script:**

```bash
curl -sS -H "Authorization: Bearer $TOKOO_API_KEY"   "https://www.tokoo.app/api/v1/importers/search?hs=8471&dest=DE&limit=10"
```

OpenAPI 3.1: https://www.tokoo.app/api/openapi.json · For agents:
https://www.tokoo.app/llms.txt

## Pricing

- Searching, company profiles, trade history and masked contacts are **free**.
- Unlocking a contact's email or phone costs **1 credit per contact per
  channel** (100 credits = $1).
- Every skill shows the cost and asks before it spends anything.

## Develop

```bash
bash scripts/sync-reference.sh      # copy reference/api.md into every skill
bash scripts/lint-skills.sh         # frontmatter, manifests, eval files
eval/find-importers/run.sh train 3  # trigger eval (needs the claude CLI and jq)
```

- Edit only `reference/api.md`. Run `bash scripts/sync-reference.sh --check` before a push: it fails if a skill's `reference.md` drifts
  from it.
- The evals allow only the Skill tool and never use
  `--dangerously-skip-permissions`.

Layout follows [nostrband/ServiceGraph](https://github.com/nostrband/ServiceGraph).

## Responsible use

Contacts are real people in business roles. Follow the anti-spam and
data-protection law that applies to you, and honor opt-outs. Don't resell the
data or bulk-scrape it (see the API terms).

## License

MIT
