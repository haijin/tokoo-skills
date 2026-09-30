---
name: tokoo
description: Use when the user names Tokoo (tokoo.app, "the Tokoo API", "Tokoo MCP") or asks what Tokoo can do, how to connect it, their Tokoo credit balance, API keys, errors, or unlocked contacts. General entry point to the Tokoo trade-intelligence API (api.tokoo.app, mcp.tokoo.app), which covers importers, buyers and suppliers found from real customs and shipment flows, filterable by HS code and country, with paid contact unlocks. For a concrete task that doesn't mention Tokoo, prefer the task skills (find-importers, find-buyers-for-my-product, find-distributors, check-company-trade). Skip general trade statistics questions (country-level import totals, tariffs), which are not what Tokoo sells.
version: "0.1.0"
metadata:
  api_base: https://api.tokoo.app/v1
  mcp_url: https://mcp.tokoo.app/mcp
---

# tokoo

General entry point for the **Tokoo API**. Read `reference.md` (next to this
file) before the first call. It lists the endpoints, costs, errors, and rules.

## What to do

1. **Connection.** If MCP tools with `tokoo` in their names are available, use
   them. Otherwise use REST with `TOKOO_API_KEY` loaded from `.env.local` in a
   subshell (see reference.md). If neither is set up, walk the user through one
   of these:
   - Claude Code: `claude mcp add --transport http tokoo https://mcp.tokoo.app/mcp`
   - claude.ai / ChatGPT: add a custom connector with URL `https://mcp.tokoo.app/mcp`
   - Scripts: create a key at https://www.tokoo.app/app/developers and put
     `TOKOO_API_KEY=tk_live_...` in `.env.local`. Never paste it into the chat.
2. **Account questions.**
   - Balance: `get_credit_balance` or `GET /v1/me/credits`.
   - Spend history: `GET /v1/me/credits/transactions`.
   - Owned contacts: `GET /v1/unlocks`.
3. **Errors.** Look up the error `code` in the table in reference.md and tell
   the user the concrete next step (top up, rotate the key, or wait `Retry-After`).
4. **Tasks.** For "find buyers/importers/distributors" or "check this company",
   follow the workflow of the matching task skill.

## When NOT to use this skill

- Country-level trade statistics, tariff rates, customs rules: Tokoo doesn't provide these.
- Consumer shopping or price comparison.
- Anything that needs personal data about someone outside a business role.
