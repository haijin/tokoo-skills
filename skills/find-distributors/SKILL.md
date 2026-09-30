---
name: find-distributors
description: Use when the user wants distributors, wholesalers, dealers, stockists or trading companies in a specific country for a product category, e.g. "find distributors of industrial valves in Saudi Arabia", "wholesalers for kitchen appliances in Nigeria", "who could be our exclusive dealer for dental equipment in Chile", "trading companies in the UAE that re-export electronics". Drives the Tokoo API (api.tokoo.app / mcp.tokoo.app). It finds companies with the buyer role in that country and favors those whose shipments show repeat imports of the category from several suppliers, which is a distributor pattern rather than an end user. It then lists masked contacts, with paid unlocks. Skip retail store locators, consumer "where can I buy X" questions, logistics or freight forwarders, and hiring sales agents as employees.
version: "0.1.0"
metadata:
  api_base: https://api.tokoo.app/v1
  mcp_url: https://mcp.tokoo.app/mcp
  primary_tool: search_importers
---

# find-distributors

Find companies that **resell** a category in a country, not just any importer.
Read `reference.md` first for costs, errors and key handling.

## Workflow

1. **Pin the category and country.** Map the category to 1-3 HS codes with
   `search_hs_codes`, and use ISO2 for the country.
2. **Find candidates two ways**, then merge the two lists by company id:
   - `search_importers` (`hs`, `dest`, `months: 12`, `min_shipments: 4`).
   - `search_companies` (`country`, `role: buyer`, and `q` with words like
     "distributor", "wholesale", "trading" or "dealer" plus the category).
3. **Score the distributor pattern.** Call `get_trade_history` on the top ~10.
   - Likely a distributor: several suppliers or origin countries, regular
     shipments, and a range of related HS codes.
   - Likely an end user or manufacturer: one supplier and one code.

   Tell the user which signal you used.
4. **Present 5-10 companies**: name, city, why they look like a distributor,
   last shipment, and whether contacts exist.
5. **Contacts.** Call `list_contacts` and favor owner/MD, business development,
   purchasing, and product/brand manager titles.
6. **Unlock only with consent.** Run a `confirm: false` preview, tell the user
   the cost and their balance, and wait for a yes.

## When NOT to use this skill

- "Where can I buy X near me" is consumer retail.
- Freight forwarders, customs brokers, 3PLs.
- Recruiting individual sales reps or agents as employees.
