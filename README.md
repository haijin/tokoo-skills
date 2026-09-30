# Tokoo skills + MCP

Agent skills and MCP config for the **Tokoo API**. Tokoo finds the real
importers, buyers and distributors behind customs and shipment flows. You can
filter them by HS code and country, check a company's trade record, and unlock
buyer contacts with credits.

> **Status: private beta.** `mcp.tokoo.app` and `api.tokoo.app` are not public
> yet. To join the beta, contact us through https://www.tokoo.app.

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

## Connect

**MCP (recommended).** OAuth sign-in happens in your browser, and no key
enters the chat.

```bash
claude mcp add --transport http tokoo https://mcp.tokoo.app/mcp
```

In claude.ai or ChatGPT, add a custom connector with the URL
`https://mcp.tokoo.app/mcp`.

**Skills.** Pick one of these:

```bash
npx skills add haijin/tokoo-skills                    # all skills
npx skills add haijin/tokoo-skills --skill find-importers
```

As a Claude Code plugin:

```bash
claude plugin marketplace add haijin/tokoo-skills
claude plugin install tokoo@tokoo
```

**REST.** Create a key at https://www.tokoo.app/app/developers and put it in
`.env.local`, which is gitignored:

```
TOKOO_API_KEY=tk_live_...
```

```bash
( set -a; . ./.env.local; set +a
  curl -sS -H "Authorization: Bearer $TOKOO_API_KEY" \
    "https://api.tokoo.app/v1/importers/search?hs=8471&dest=DE&limit=10" )
```

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

- Edit only `reference/api.md`. CI fails if a skill's `reference.md` drifts
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
