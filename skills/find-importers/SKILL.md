---
name: find-importers
description: Use whenever the user wants the actual companies that import a product or HS code into a country or region, e.g. "who imports HS 8471 into Germany", "list importers of solar inverters in Brazil", "top buyers of 6109 cotton t-shirts shipping into the US from Vietnam", "which companies bring LED lighting into Poland", including indirect asks like "who are the overseas buyers for our HS code" or "find customers in Mexico importing what we make" when an HS code or clear product and destination are given. Drives the Tokoo API (api.tokoo.app / mcp.tokoo.app), which returns company-level importers ranked by real shipment evidence, then masked contacts and paid email/phone unlocks. Skip country-level import statistics or totals, tariff or duty questions, and finding suppliers or factories (the user buying, not selling). If the user describes their product but has no HS code and no target country yet, use find-buyers-for-my-product instead.
version: "0.1.0"
metadata:
  api_base: https://api.tokoo.app/v1
  mcp_url: https://mcp.tokoo.app/mcp
  primary_tool: search_importers
---

# find-importers

Find the **companies** importing a product into a destination, ranked by real
shipment evidence, and help the user reach their buyers. Read `reference.md`
first for costs, errors and key handling.

## Workflow

1. **Pin the HS code.** If the user gave one, use it (4 or 6 digits). A 2-digit
   chapter is too broad, so ask them to narrow it. If they gave a product name,
   call `search_hs_codes` (`GET /v1/hs?q=`), and if more than one code fits,
   confirm the choice with the user.
2. **Pin the destination** as ISO2 codes (`DE`, `BR`, `US`). For a region like
   "EU" or "LATAM", ask which 2-5 countries matter most, then query each one.
3. **Search.** Call `search_importers` with `hs` and `dest` (both lists),
   `min_shipments` (default 3) and `limit` 10. To find buyers already importing
   from the user's own country, check `get_trade_history` counterparts on the
   top results; the search itself has no origin filter yet.
4. **Present a short table** with these columns: company, city/country,
   shipments in the window, last shipment date, matching HS codes, and whether
   contacts exist (`contact_count`). Explain *why* each company is on the list.
5. **Go deeper on request.**
   - `get_trade_history` gives lanes and counterparties.
   - `list_contacts` gives masked buyers. The usual targets are procurement,
     purchasing, supply chain, sourcing, import and category manager titles.
6. **Unlock only with consent.**
   - Call `unlock_contacts` with `confirm: false`.
   - Tell the user: "This unlocks N emails for N credits. You have B credits."
     Wait for a yes.
   - Call it again with `confirm: true`.
   - Report the outcome for each contact. `refunded_retry_ok` means you can retry.

## When NOT to use this skill

- "How much does Germany import of 8471 per year?" asks for aggregate
  statistics, not companies.
- "Find me a factory that makes X" is sourcing suppliers. Use
  `search_companies` with `role: supplier` via the `tokoo` skill, or decline.
- Duties, tariffs, HS classification disputes, customs clearance.
- The user gives no product and no country: ask, or use find-buyers-for-my-product.
