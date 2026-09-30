# Tokoo API reference (shared by every skill)

<!-- SOURCE OF TRUTH. Edit this file only, then run scripts/sync-reference.sh.
     Each skill ships its own copy (skills/<name>/reference.md) because
     `npx skills add --skill <name>` installs a single skill folder. CI fails
     if a copy drifts from this file. -->

> **Status: private beta.** `api.tokoo.app` and `mcp.tokoo.app` are not public
> yet. If a call fails to connect, tell the user the Tokoo API is in private
> beta and point them to https://www.tokoo.app/developers.

## Two ways in

1. **MCP (preferred).** If any tool name contains `tokoo` (for example
   `search_importers`), use the MCP tools. Auth is OAuth, handled by the client;
   the token never enters the conversation.
   - Claude Code: `claude mcp add --transport http tokoo https://mcp.tokoo.app/mcp`
   - claude.ai / ChatGPT: add a custom connector with URL `https://mcp.tokoo.app/mcp`
2. **REST fallback.** `https://api.tokoo.app/v1`, header
   `Authorization: Bearer $TOKOO_API_KEY`. Keys look like `tk_live_…` and are
   created at https://www.tokoo.app/app/developers.

**Never print, echo, or ask the user to paste the key into the chat.** Load it
from `.env.local` in a subshell:

```bash
( set -a; [ -f .env.local ] && . ./.env.local; set +a
  curl -sS -H "Authorization: Bearer $TOKOO_API_KEY" \
    "https://api.tokoo.app/v1/me/credits" )
```

## Cost model

- **Free:** every search, company profile, trade history, and the masked
  contact list (name, title, seniority, `has_email`, `has_phone`).
- **Paid:** unlocking a contact's email or phone costs **1 credit per contact
  per channel** (100 credits = $1). A channel the org already owns costs 0.
- **Always preview before paying.** Call `unlock_contacts` with
  `confirm: false` (or count the ids yourself for REST), tell the user the exact
  credit cost and their balance, and only unlock after they say yes.
- Unlocks are all-or-nothing at reservation: if the balance is short you get
  402 and nothing is charged. Delivery is per contact; failed deliveries are
  refunded automatically.

## MCP tools

| Tool | Cost | Purpose |
|---|---|---|
| `search_hs_codes` | free | Product words → HS codes (`q`) |
| `search_importers` | free | Importers by `hs` (list of codes or prefixes), `dest` (list of ISO2), optional `min_shipments` (default 3), `limit` ≤ 50. Most shipments first; one page, no cursor |
| `search_companies` | free | Companies by `q` (name words), `country` (ISO2 list), `role` (`buyer`/`supplier`), `hs`; `limit`, `cursor` |
| `get_company` | free | Profile, trade totals and top HS codes for one `company_id` |
| `get_trade_history` | free | HS mix, recent shipments and counterparties over 24 months for `company_id` (`hs` filter, `limit`) |
| `list_contacts` | free | Contacts at a `company_id`: title, seniority, masked channels, `unlockable: {email, phone}` |
| `unlock_contacts` | **paid** | `{field: "email"\|"phone", company_id, contact_ids[≤50], confirm, idempotency_key?}`. All contacts must be at that one company |
| `get_credit_balance` | free | Current balance |

## REST endpoints

| Method | Path | Cost |
|---|---|---|
| GET | `/v1/hs?q=` | free |
| GET | `/v1/importers/search?hs=&dest=&min_shipments=&limit=` | free |
| GET | `/v1/companies/search?q=&country=&role=&hs=&limit=&cursor=` | free |
| GET | `/v1/companies/{id}` | free |
| GET | `/v1/companies/{id}/trade?hs=&limit=` | free |
| GET | `/v1/companies/{id}/contacts` | free (masked) |
| POST | `/v1/unlocks` body `{field, company_id, contact_ids, idempotency_key}` | **paid**; `idempotency_key` required (use a fresh UUID per intended purchase) |
| GET | `/v1/unlocks?limit=` | free; contacts the org already owns, with values |
| GET | `/v1/me`, `/v1/me/credits`, `/v1/me/credits/transactions` | free |

Repeated query parameters and comma lists both work for lists: `hs=8504&hs=8541` or
`hs=8504,8541`. Pagination (company search): pass `next_cursor` back as `cursor`;
`null` means the end. The full schema is at `https://api.tokoo.app/openapi.json`.

## Unlock outcomes (per contact)

Each result has `contact_id` and `status`:

- `revealed`: `name` and `value` (the email or phone) returned.
- `already_owned`: `name` and `value` returned, cost 0.
- `refunded_retry_ok`: delivery failed and was refunded; retrying is safe.
- `replay_refunded`: you reused an idempotency key for an unlock that was
  refunded; retry with a **new** key.
- `pending`: still in flight; check `GET /v1/unlocks` shortly.

## Errors

All errors are `{ "error": { "code", "message", "details"? } }`.

| Status | Code | What to do |
|---|---|---|
| 400 | `invalid_params` | Fix the parameters named in `message` |
| 401 | `unauthorized` / `key_expired` | Ask the user to create or rotate a key at /app/developers (or reconnect the connector) |
| 402 | `insufficient_credits` | Tell the user `details.needed` vs `details.balance`; nothing was charged; top up at /app/billing |
| 403 | `scope_required` / `monthly_cap_reached` / `org_suspended` / `api_disabled` | Explain; don't retry |
| 404 | `not_found` | Never charged; check the id |
| 422 | `idempotency_key_reused` | Same key, different request; use a new key |
| 429 | `rate_limited` | Wait `Retry-After` seconds; the daily brief cap resets at 00:00 UTC |
| 503 | `temporarily_unavailable` | Wait `Retry-After`, then retry once |

Every response carries `X-RateLimit-Limit`, `X-RateLimit-Remaining`,
`X-RateLimit-Reset`. Limits: 60 requests/min per key, 2,000 result rows/day per
org, 10 unlock calls/min.

## Rules for every skill

- Do not guess or invent contact details, and do not claim where the data comes
  from. Report what the API returns.
- Contacts are real people. Remind users who plan outreach to follow local
  anti-spam and data-protection law and to honor opt-outs.
- Keep result lists short (default 10), show the trade evidence (shipments,
  last seen, HS match) that makes each company relevant, and offer to go deeper.
